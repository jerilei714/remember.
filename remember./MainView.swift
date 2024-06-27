//
//  MainView.swift
//  remember.
//
//  Created by Jeri Lei on 6/29/24.
//

import SwiftUI

struct MainView: View {
    @Binding var userName: String
    @State private var showPersonalizeScreen = false
    @State private var categories: [String] = []
    @State private var items: [String: [Item]] = [:]
    @State private var currentCategory = ""
    @State private var newItem = ""
    @State private var showCategoryScreen = false
    @State private var showItemScreen = false
    @State private var showOverviewScreen = false
    @State private var selectedCategory = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showCompletionAlert = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var buttonTextColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    struct Item: Identifiable {
        var id = UUID()
        var name: String
        var isChecked: Bool
    }

    var body: some View {
        VStack {
            if !showPersonalizeScreen {
                welcomePage
            } else if !showCategoryScreen {
                categoryAddingPage
            } else if !showItemScreen {
                itemAddingPage
            } else if !showOverviewScreen {
                checklistPage
            } else {
                overviewPage
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("You are all set!"),
                message: Text("You have everything you need, good luck!"),
                dismissButton: .default(Text("Yey!"))
            )
        }
    }

    // Welcome Page
    var welcomePage: some View {
        VStack {
            Text("Welcome to Remember, \(userName.isEmpty ? "Guest" : userName)!")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
            
            TextField("Enter your name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    if userName.isEmpty {
                        alertMessage = "Please enter your name."
                        showAlert = true
                    } else {
                        showPersonalizeScreen = true
                    }
                }

            Button(action: {
                if userName.isEmpty {
                    alertMessage = "Please enter your name."
                    showAlert = true
                } else {
                    showPersonalizeScreen = true
                }
            }) {
                Text("Start Personalizing")
                    .font(.headline)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // Category Adding Page
    var categoryAddingPage: some View {
        VStack {
            Text("Need to remember some things, \(userName)?")
                .font(.title)
                .padding()

            TextField("Enter category", text: $currentCategory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if currentCategory.isEmpty {
                    alertMessage = "Please enter a category name."
                    showAlert = true
                } else {
                    categories.append(currentCategory)
                    items[currentCategory] = []
                    currentCategory = ""
                }
            }) {
                Text("Add Category")
                    .font(.headline)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(10)
            }

            List {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        Button(action: {
                            if let index = categories.firstIndex(of: category) {
                                categories.remove(at: index)
                                items.removeValue(forKey: category)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            Button(action: {
                showCategoryScreen = true
            }) {
                Text("Finish Adding Categories")
                    .font(.headline)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // Item Adding Page
    var itemAddingPage: some View {
        VStack {
            Text("Give me your list and remember now, \(userName).")
                .font(.title)
                .padding()

            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        showItemScreen = true
                    }) {
                        HStack {
                            Text(category)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    // Checklist Page
    var checklistPage: some View {
        VStack {
            Text("What do you need to remember for \(selectedCategory), \(userName)?")
                .font(.title)
                .padding()

            TextField("Enter item", text: $newItem)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if newItem.isEmpty {
                    alertMessage = "Please enter an item name."
                    showAlert = true
                } else {
                    items[selectedCategory]?.append(Item(name: newItem, isChecked: false))
                    newItem = ""
                }
            }) {
                Text("Add Item")
                    .font(.headline)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(10)
                    .animation(.easeInOut)
            }

            List {
                ForEach(items[selectedCategory] ?? [], id: \.id) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button(action: {
                            if let index = items[selectedCategory]?.firstIndex(where: { $0.id == item.id }) {
                                items[selectedCategory]?.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
            }

            Button(action: {
                showOverviewScreen = true
            }) {
                Text("Finish Adding Items")
                    .font(.headline)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(10)
                    .animation(.easeInOut)
            }
        }
        .padding()
    }

    // Overview Page
    var overviewPage: some View {
        VStack {
            HStack {
                Button(action: {
                    showOverviewScreen = false
                    showCategoryScreen = true
                    showItemScreen = false
                }) {
                    Text("< Add Items")
                        .font(.headline)
                        .padding()
                        .foregroundColor(buttonTextColor)
                        .background(buttonBackgroundColor)
                        .cornerRadius(10)
                }
                Spacer()
                Button(action: {
                    showOverviewScreen = false
                    showCategoryScreen = false
                    showItemScreen = false
                }) {
                    Text("Add Categories >")
                        .font(.headline)
                        .padding()
                        .foregroundColor(buttonTextColor)
                        .background(buttonBackgroundColor)
                        .cornerRadius(10)
                }
            }
            .padding()

            Text("Remember these, \(userName)")
                .font(.title)
                .padding()

            List {
                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: itemListView(for: category)) {
                        Text(category)
                    }
                }
            }
            .padding()
        }
        .padding()
    }

    // Item List View for a Category
    func itemListView(for category: String) -> some View {
        VStack {
            Text("Items for \(category)")
                .font(.title)
                .padding()

            List {
                ForEach(items[category] ?? [], id: \.id) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button(action: {
                            if let index = items[category]?.firstIndex(where: { $0.id == item.id }) {
                                items[category]?[index].isChecked.toggle()
                                if items[category]?.allSatisfy({ $0.isChecked }) == true {
                                    // Show alert when all items are checked
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showCompletionAlert = true
                                    }
                                }
                            }
                        }) {
                            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                        }
                    }
                }
            }
            .background(Color.white)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(userName: .constant("User"))
    }
}
