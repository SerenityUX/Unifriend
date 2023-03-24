//
//  ContentView.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 3/24/23.
//

import SwiftUI
import OneSignal

func sendRequest(parameters: [String: Any]) async {
    let recipientID = parameters["recipientID"] as? Int ?? 0


    let urlString = "https://unifriendapi.onrender.com/sendConvo?recipientID=\(recipientID)&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
    
    
    print(urlString)
    guard let url = URL(string: urlString) else {
        // Handle invalid URL error
        return
    }
    
    // Create a GET request with the URL
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    _ = URLSession.shared

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        // Parse the JSON data
        print(String(data: data, encoding: .utf8) ?? "Cannot Get")
    } catch {
        print("Error decoding JSON: \(error)")
        // Handle errors here
    }
        
    
}

struct ContentView: View {

    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    @State var hasNoAccountInfo = false
    @State var hasNoEvents = false
    @State var hasNoHobbies = false

    @State var hasNoProfileInfo = false

    @State var isActiveMove = false
    @State private var message: String? = nil
    @State var suggestions: [User] = []

    @State var selectedConversation: Conversation?
    @State var userSelf = selfStructure(auth_token: "", id: -1, name: "", phone_number: "")
    
    
    func getMessages() async -> [Conversation?] {
        let urlString = "https://unifriendapi.onrender.com/getConvos?auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
        guard let url = URL(string: urlString) else {
            // Handle invalid URL error
            return []
        }

        // Create a GET request with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Create a URLSession object
        let session = URLSession.shared

        // Create a data task with the request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            conversations = try decoder.decode([Conversation].self, from: data)
            // Now `conversations` is an array of `Conversation` objects
        } catch {
            print("Error decoding JSON: \(error)")
            // Handle errors here
        }
        return []
    }
    func getSuggestions() async -> [User] {
        let urlString = "https://unifriendapi.onrender.com/getSuggestions?auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
        guard let url = URL(string: urlString) else {
            // Handle invalid URL error
            return []
        }

        // Create a GET request with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Create a URLSession object
        let session = URLSession.shared

        // Create a data task with the request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            var suggestionHolder = try decoder.decode([User].self, from: data)
            suggestions = suggestionHolder
            return suggestionHolder
        } catch {
            print("Error decoding JSON: \(error)")
            // Handle errors here
        }
        return suggestions
    }

    func checkAuth() async -> Bool {
        print("Checking Auth")
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        print("token: " + token)
        if (token == "") {
            OneSignal.setExternalUserId("")
            return false
        } else {
            
            if let url = URL(string: "https://unifriendapi.onrender.com/auth?auth_token=\(token)") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                // Create a dictionary to hold the request body data
                
                
                // Serialize the dictionary to JSON and set it as the request body
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: [], options: [])
                    request.httpBody = jsonData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch let error {
                    print("Error serializing request body: \(error.localizedDescription)")
                    OneSignal.setExternalUserId("")
                    return false
                }
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let responseDictionary = json as? [String: Any] {
                        let authSuccess = responseDictionary["auth"] as? Bool ?? false
                        if authSuccess {
                            if let selectedSelf = responseDictionary["self"] as? [String: Any] {
                                print("University below")
                                let University = selectedSelf["university"] as? String ?? ""
                                let Avatar = selectedSelf["avatar"] as? String ?? ""
                                let EventsInterestedIn = selectedSelf["events"] as? [String] ?? [String]()
                                let HobbiesInterestedIn = selectedSelf["hobbies"] as? [String] ?? [String]()
                                print(selectedSelf)
                                if(University == "") {
                                    hasNoAccountInfo =  true
                                } else if (Avatar == "") {
                                    hasNoProfileInfo =  true
                                } else if (EventsInterestedIn.isEmpty) {
                                    hasNoEvents = true
                                } else if (HobbiesInterestedIn.isEmpty) {
                                    hasNoHobbies = true
                                }
                                
                                
                                userSelf = selfStructure(
                                    auth_token: selectedSelf["auth_token"] as? String ?? "",
                                    id: selectedSelf["id"] as? Int ?? -1,
                                    name: selectedSelf["name"] as? String ?? "",
                                    phone_number: selectedSelf["phone_number"] ?? ""
                                )
                                
                            }
                            print("right here?")

                            print("Your id: \(userSelf.id)")
                            OneSignal.setExternalUserId(String(userSelf.id))

                            return true
                        } else {
                            OneSignal.setExternalUserId("")
                            return false
                        }
                    } else {
                        OneSignal.setExternalUserId("")
                        return false
                    }
                } catch {
                    OneSignal.setExternalUserId("")
                    return false
                }
                
            }
            
            
        }
        OneSignal.setExternalUserId("")
        return false
    }
    
    //Should be false
    @State private var invalidAuth = false
    
    @State private var conversations = [Conversation]()
    @State private var showingSheet = false

    
    var body: some View {
        VStack {
            
        
            ScrollView() {
                

            NavigationLink(destination: conversationView(selectedConversation: selectedConversation), isActive: $isActiveMove) { EmptyView() }
            
            NavigationLink(destination: onboarding(), isActive: $invalidAuth) { EmptyView() }
                NavigationLink(destination: accountSetup().onAppear{
                    hasNoAccountInfo = false
                }, isActive: $hasNoAccountInfo) { EmptyView() }
            NavigationLink(destination: profileSetup().onAppear {
                hasNoProfileInfo = false
            }, isActive: $hasNoProfileInfo) { EmptyView() }
            NavigationLink(destination: eventSelection().onAppear {
                hasNoEvents = false
            }, isActive: $hasNoEvents) { EmptyView() }
                
//                Add Later
//            NavigationLink(destination: hobbySelection().onAppear {
//                hasNoHobbies = false
//            }, isActive: $hasNoHobbies) { EmptyView() }
                Button(action: {
                    
                    Task {
                        suggestions = await getSuggestions()
                        print(suggestions)
                        showingSheet.toggle()

                    }

                    
                    
                }) {
                    HStack{
                        ZStack{
                            
                            Image("FindFriends")
                                .resizable()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [.clear, Color.green]
                                        ),
                                        startPoint: UnitPoint(x: 0.5, y: 0.25),
                                        endPoint: UnitPoint(x: 0.5, y: 0.75)
                                    )
                                )
                            VStack{
                                Spacer()
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("Find Friends, a call to connect")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                        Text("A message sent, a friendship to collect.")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                        HStack{
                                            Text("Scavenge for Friends")
                                                .foregroundColor(.green)
                                                .font(.subheadline)
                                                .padding(.vertical, 6)
                                            
                                                .padding(.horizontal, 12)
                                        }
                                        .background(Color.white)
                                        
                                        .cornerRadius(32)
                                        
                                        
                                        
                                        
                                    }
                                    Spacer()
                                }
                                
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .opacity(1)
                                
                            }
                        }

                    }
                    .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .padding()
                    }
                .sheet(isPresented: Binding(
                  get: { self.showingSheet && !self.suggestions.isEmpty },
                  set: { self.showingSheet = $0 }
                )) {
                  SheetView(suggestions: self.suggestions)
                }
                .buttonStyle(CustomButtonStyle())

                if let firstName = userSelf.name.split(separator: " ").first {
                    HStack{
                        
                        
                        Text("\(String(firstName))'s Messages")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        Spacer()
                        
                    }
                        
                    
                        ForEach(conversations) { conversation in
                            HStack {
                                Image(conversation.user.avatar ?? "")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(48)
                                    .background(Circle().foregroundColor(.gray))
                                
                                VStack(alignment: .leading) {
                                    Text(String(conversation.user.name))
                                        .font(.headline)
                                    Text(String(conversation.lastMessageContent).prefix(42) + "...")
                                }
                                Spacer()
                            }
                            

                            .onTapGesture {
                                print(conversation)
                                selectedConversation = conversation
                                isActiveMove = true
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    

                    Button("Logout") {
                        Task {
                            
                            UserDefaults.standard.removeObject(forKey: "token")
                            await self.invalidAuth = !checkAuth()
                        }
                    }
                    .padding(.all)
                } else {
                ProgressView() .progressViewStyle(CircularProgressViewStyle())
                
            }
                Spacer()
            }.navigationBarTitle(userSelf.name != nil ? "Convos" : "None")

        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .onAppear {
            Task {
                
                print("Aye there")
                self.invalidAuth = await !checkAuth()
                print("this code runs")
                await getMessages()
            }
        }
        .onReceive(timer) { _ in
            Task {
                await getMessages()
            }
        }


    }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView()
    }
}


struct selfStructure {
    var auth_token: String
    var id: Int
    var name: String
    var phone_number: Any
}

struct Conversation: Codable, Identifiable {
    let id: Int
    let isAccepted: Bool
    let lastMessageDate: String
    let lastMessageContent: String
    let messages: [Message]
    let user: User
}


struct Message: Codable {
    let content: String
    let conversationID: Int
    let date: String
    let isImage: Bool
    let messageID: Int?
    let recipient: Int
    let sender: Int
}

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let phoneNumber: String
    let major: String?
    let bio: String?
    let avatar: String?
    let university: String?
    let grad_year: String?
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .rotationEffect(configuration.isPressed ? .degrees(Double.random(in: -15...15)) : .degrees(0))

            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SheetView: View {
    @State var isActiveMove = false

    @Environment(\.dismiss) var dismiss
    @State var suggestions: [User]

    var body: some View {
        HStack(alignment: .top){
            
            
            VStack(alignment: .leading){
                HStack{
                    
                    
                    Text("Find Friends")
                        .padding()
                    Spacer()
                    Button("Dismiss") {
                        dismiss()
                    }
                    .padding()
                }
                
                ForEach(suggestions) { suggestion in
                    HStack{
                        
                        
                        Image(suggestion.avatar ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .cornerRadius(32)
                            .background(Circle().foregroundColor(.gray))
                        Text(String(suggestion.name))
                            .font(.headline)
                        Spacer()
                        
                        
                        
                        
                        Button ("Add Friend") {
                            Task {
                                await sendRequest(parameters: ["recipientID": suggestion.id])
                                dismiss()

                            }
                        }
                        

                    }.padding()
                    
                }
                Spacer()
            }
        }
    }
}
