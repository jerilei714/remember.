//
//  ContentView.swift
//  remember.
//
//  Created by Jeri Lei on 6/27/24.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var userName = ""
    @State private var emojiKey = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showWelcomePage = false

    var body: some View {
        NavigationView {
            if isLoggedIn {
                MainView(userName: $userName)
            } else if showWelcomePage {
                welcomeView
            } else {
                loginView
            }
        }
    }

    var loginView: some View {
        VStack {
            Text("Welcome to Remember")
                .font(.largeTitle)
                .padding()

            TextField("Enter your 24-emoji key", text: $emojiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    authenticate()
                }

            Button("Login with Face ID") {
                authenticateWithFaceID()
            }
            .padding()

            Button("Generate New Key") {
                generateEmojiKey()
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
    }

    var welcomeView: some View {
        VStack {
            Text("Welcome, \(userName)!")
                .font(.largeTitle)
                .padding()

            TextField("Enter your username", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    updateUsername()
                }

            Button("Save Username") {
                updateUsername()
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
    }

    private func generateEmojiKey() {
        let emojis = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "😵", "🤯", "🤠", "😎", "🤓", "🧐", "😕", "😟", "🙁", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🙈", "🙉", "🙊", "💥", "💫", "💦", "💨", "🐵", "🐒", "🦍", "🦧", "🐶", "🐕", "🐩", "🐺", "🦊", "🦝", "🐱", "🐈", "🦁", "🐯", "🐅", "🐆", "🐴", "🐎", "🦄", "🦓", "🦌", "🦬", "🐮", "🐂", "🐃", "🐄", "🐷", "🐖", "🐗", "🐽", "🐏", "🐑", "🐐", "🐪", "🐫", "🦙", "🦒", "🐘", "🦣", "🦏", "🦛", "🐭", "🐁", "🐀", "🐹", "🐰", "🐇", "🐿️", "🦫", "🦔", "🦇", "🐻", "🐨", "🐼", "🦥", "🦦", "🦨", "🦘", "🦡", "🐾", "🦃", "🐔", "🐓", "🐣", "🐤", "🐥", "🐦", "🐧", "🕊️", "🦅", "🦆", "🦢", "🦉", "🦤", "🪶", "🦩", "🦚", "🦜"]
        let key = (0..<24).map { _ in emojis.randomElement()! }.joined()
        self.emojiKey = key
        DatabaseManager.shared.addUser(username: "Guest", key: key) // Use a default username or handle in the UI
        alertMessage = "Your new 24-emoji key is \(key). Please keep it secure."
        showAlert = true
    }

    private func authenticate() {
        if let user = DatabaseManager.shared.getUser(byKey: emojiKey) {
            if user.username == "Guest" {
                showWelcomePage = true
            } else {
                userName = user.username
                isLoggedIn = true
            }
        } else {
            alertMessage = "Invalid emoji key."
            showAlert = true
        }
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in with Face ID") { success, authenticationError in
                if success {
                    DispatchQueue.main.async {
                        // Handle Face ID login
                        self.isLoggedIn = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Face ID authentication failed."
                        self.showAlert = true
                    }
                }
            }
        } else {
            alertMessage = "Face ID not available."
            showAlert = true
        }
    }

    private func updateUsername() {
        if !userName.isEmpty {
            if let user = DatabaseManager.shared.getUser(byKey: emojiKey) {
                DatabaseManager.shared.addUser(username: userName, key: emojiKey) // Update username
                isLoggedIn = true
                showWelcomePage = false
            }
        } else {
            alertMessage = "Username cannot be empty."
            showAlert = true
        }
    }
}