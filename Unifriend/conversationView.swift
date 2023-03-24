//
//  conversationView.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 3/26/23.
//

import SwiftUI


struct conversationView: View {
    @State var selectedConversation: Conversation?
    @State private var messageInputted: String = ""

    @State var messages: [MessageContainer]

    
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

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
            return try decoder.decode([Conversation].self, from: data)
            // Now `conversations` is an array of `Conversation` objects
        } catch {
            print("Error decoding JSON: \(error)")
            // Handle errors here
        }
        return []
    }
    
    init(selectedConversation: Conversation?) {
        self.selectedConversation = selectedConversation
        self._messages = State(initialValue: selectedConversation?.messages.map { message in
            let id = message.messageID
            return MessageContainer(message: message)
        } ?? [])
    }
    
    func updateMessage() async {
        do {
            let conversations = await getMessages()
            
            for conversation in conversations {
                if (conversation?.id == selectedConversation?.id) {
                    selectedConversation = conversation
                    var temporaryStore: [MessageContainer] = []
                    for message in conversation?.messages ?? [] {
                        temporaryStore.append(MessageContainer(message: message))
                    }
                        
                    messages = temporaryStore
                }
            }
            print("We're Ready")
            await print(getMessages())
            print("Should be updated")

        } catch {
            print("Error")
        }
    }
    
    func sendMessage() async {
        if(messageInputted != "") {
            let relationshipID = Int(selectedConversation!.id)
            let recipientID = Int((selectedConversation?.user.id)!)
            
            
            let urlString = "https://unifriendapi.onrender.com/sendMessage?content=\(messageInputted.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&relationshipID=\(relationshipID)&recipientID=\(recipientID)&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
            
            
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
                messages.append(MessageContainer(message: Message(content: messageInputted, conversationID: selectedConversation!.id, date: String(Date().ISO8601Format()), isImage: false, messageID: UUID().hashValue,  recipient: (selectedConversation?.user.id)!, sender: 0)))
                // Now `conversations` is an array of `Conversation` objects
                messageInputted = ""
            } catch {
                print("Error decoding JSON: \(error)")
                // Handle errors here
            }
            
        }
    }


    
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { message in
                        HStack {
                        if selectedConversation?.user.id != message.message.sender {
                                Spacer()
                                Text(message.message.content)
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .background(Color(hex: 0x72B781))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .id(message.id)
                                    .onTapGesture {
                                        print(message.id)
                                    }
                                    
                            } else {
                                Text(message.message.content)
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .background(Color(hex: 0xEEFEF2))
                                    .foregroundColor(.black)
                                    .cornerRadius(16)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                }                .onChange(of: messages) { messages in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }

                }
                .onAppear {
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .padding(.vertical, 16)
                
            }
            .frame(maxWidth: .infinity) // Add this line

            .onAppear {
                Task {
                    await updateMessage()
                }
            }


            


        }
        .onReceive(timer) { _ in
            Task {
                await updateMessage()
                print("timer runs")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
            TextField("Message", text: $messageInputted)
                .padding()
                .textFieldStyle(.roundedBorder)
                Button {
                    Task {
                        //Stores the URL as a URL
                        await sendMessage()
                        
                    }
                } label: {
                    Text("Send")
                        .padding(.trailing)

                }
            }
                .textFieldStyle(.roundedBorder)
                .background(.ultraThinMaterial)


        }

        .navigationBarTitle(selectedConversation?.user.name ?? "Conversation", displayMode: .inline)
        .navigationBarItems(trailing:
            HStack {
            Image(selectedConversation?.user.avatar ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .cornerRadius(32)
                // Add other leading navigation bar items as needed
            }
        )

        .accentColor(Color(#colorLiteral(red: 0.447, green: 0.722, blue: 0.504, alpha: 1)))

    }
}

struct MessageContainer: Identifiable, Equatable {
    static func == (lhs: MessageContainer, rhs: MessageContainer) -> Bool {
        return true
    }
    
    let message: Message
    let id: Int

    static var lastID: Int = 0

    static func nextID() -> Int {
        lastID += 1
        return lastID
    }

    init(message: Message) {
        self.message = message
        self.id = Self.nextID()
    }
}


func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
