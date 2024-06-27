//
//  DatabaseManager.swift
//  remember.
//
//  Created by Jeri Lei on 6/29/24.
//

import Foundation
import SQLite

struct User {
    var id: Int64
    var username: String
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection!
    private let users = Table("User")
    private let categories = Table("Category")
    private let items = Table("Item")
    
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let emojiKey = Expression<String>("emoji_key")
    private let userId = Expression<Int64>("user_id")
    private let categoryName = Expression<String>("name")
    private let categoryId = Expression<Int64>("category_id")
    private let itemName = Expression<String>("name")
    
    private init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("remember").appendingPathExtension("sqlite3")
            db = try Connection(fileUrl.path)
            createTables()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    
    private func createTables() {
        do {
            // Check if User table exists
            let userTableExists = try db.scalar("SELECT count(name) FROM sqlite_master WHERE type='table' AND name='User'") as? Int64
            if userTableExists == 0 {
                try db.run(users.create { table in
                    table.column(id, primaryKey: true)
                    table.column(username)
                    table.column(emojiKey, unique: true)
                })
            }

            // Check if Category table exists
            let categoryTableExists = try db.scalar("SELECT count(name) FROM sqlite_master WHERE type='table' AND name='Category'") as? Int64
            if categoryTableExists == 0 {
                try db.run(categories.create { table in
                    table.column(id, primaryKey: true)
                    table.column(userId)
                    table.column(categoryName)
                    table.foreignKey(userId, references: users, id)
                })
            }

            // Check if Item table exists
            let itemTableExists = try db.scalar("SELECT count(name) FROM sqlite_master WHERE type='table' AND name='Item'") as? Int64
            if itemTableExists == 0 {
                try db.run(items.create { table in
                    table.column(id, primaryKey: true)
                    table.column(categoryId)
                    table.column(itemName)
                    table.foreignKey(categoryId, references: categories, id)
                })
            }

            // Create Indexes
            try db.run("CREATE INDEX IF NOT EXISTS idx_user_emoji_key ON User (emoji_key)")
            try db.run("CREATE INDEX IF NOT EXISTS idx_category_user_id ON Category (user_id)")
            try db.run("CREATE INDEX IF NOT EXISTS idx_item_category_id ON Item (category_id)")

            // Ensure foreign keys are enabled
            try db.run("PRAGMA foreign_keys = ON")

        } catch {
            print("Error creating tables and indexes: \(error)")
        }
    }

    func addUser(username: String, key: String) {
        do {
            let insert = users.insert(or: .replace, self.username <- username, emojiKey <- key)
            try db.run(insert)
        } catch {
            print("Insert failed: \(error)")
        }
    }

    func getUser(byKey key: String) -> User? {
        let query = users.filter(emojiKey == key)
        if let userRow = try? db.pluck(query) {
            return User(
                id: userRow[id],
                username: userRow[username]
            )
        }
        return nil
    }

    func addCategory(userId: Int64, name: String) {
        do {
            let insert = categories.insert(self.userId <- userId, categoryName <- name)
            try db.run(insert)
        } catch {
            print("Error adding category: \(error)")
        }
    }

    func getCategories(userId: Int64) -> [String] {
        do {
            let query = categories.filter(self.userId == userId)
            let categoryRows = try db.prepare(query)
            return categoryRows.map { row in
                row[categoryName]
            }
        } catch {
            print("Error retrieving categories: \(error)")
            return []
        }
    }

    func addItem(categoryId: Int64, name: String) {
        do {
            let insert = items.insert(self.categoryId <- categoryId, itemName <- name)
            try db.run(insert)
        } catch {
            print("Error adding item: \(error)")
        }
    }

    func getItems(categoryId: Int64) -> [String] {
        do {
            let query = items.filter(self.categoryId == categoryId)
            let itemRows = try db.prepare(query)
            return itemRows.map { row in
                row[itemName]
            }
        } catch {
            print("Error retrieving items: \(error)")
            return []
        }
    }

    func deleteCategory(categoryId: Int64) {
        do {
            let category = categories.filter(id == categoryId)
            try db.run(category.delete())
        } catch {
            print("Error deleting category: \(error)")
        }
    }

    func deleteItem(itemId: Int64) {
        do {
            let item = items.filter(id == itemId)
            try db.run(item.delete())
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}
