//
//  ContentView.swift
//  remember.
//
//  Created by Jeri Lei on 6/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var userName = ""
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

    struct Item: Identifiable {
        var id = UUID()
        var name: String
        var isChecked: Bool
    }

    var body: some View {
        NavigationView {
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
        }
    }

    // Welcome Page
    var welcomePage: some View {
        VStack {
            Text("Welcome to remember, \(userName)!")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
                .animation(.easeInOut) // Fade animation

            TextField("Enter your name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut) // Fade animation
            }
        }
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
            
            Text("Add \(currentCategory) to remember?")
                .font(.title2)
                .foregroundColor(.black)
                .padding()
                .animation(.easeInOut)

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
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut)
            }

            List {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }

            Button(action: {
                showCategoryScreen = true
            }) {
                Text("Finish Adding Categories")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut) // Fade animation
            }
            .background(Color.white)
            .alert(isPresented: $showCategoryScreen) {
                Alert(
                    title: Text("Are these the categories for now, \(userName)?"),
                    message: Text("You can add more later!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
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
                        Text(category)
                    }
                }
            }
            .background(Color.white)
        }
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
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut) // Fade animation
            }

            List {
                ForEach(items[selectedCategory] ?? [], id: \.id) { (item: Item) in
                    Text(item.name)
                }
            }
            .background(Color.white)

            Button(action: {
                showOverviewScreen = true
            }) {
                Text("Finish Adding Items")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut) // Fade animation
            }
            .alert(isPresented: $showOverviewScreen) {
                Alert(
                    title: Text("You are all set!"),
                    message: Text("You have everything you need, good luck!"),
                    dismissButton: .default(Text("OK")) {
                        showItemScreen = false
                        showCategoryScreen = false
                        showOverviewScreen = true
                    }
                )
            }
        }
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
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .animation(.easeInOut)
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
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .animation(.easeInOut)
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
            .background(Color.white)
        }
    }

    func itemListView(for category: String) -> some View {
        VStack {
            Text("Items for \(category)")
                .font(.title)
                .padding()

            List {
                ForEach(items[category] ?? [], id: \.id) { (item: Item) in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button(action: {
                            // Handle item checkbox
                            if let index = items[category]?.firstIndex(where: { $0.id == item.id }) {
                                items[category]?[index].isChecked.toggle()
                                if items[category]?.allSatisfy({ $0.isChecked }) == true {
                                    // Show alert when all items are checked
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showCompletionAlert()
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

    private func showCompletionAlert() {
           if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController {
               let alert = UIAlertController(title: "You are all set!", message: "You have everything you need, good luck!", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Yey!", style: .default))
               rootViewController.present(alert, animated: true)
           }
       }
   }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

