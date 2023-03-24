//
//  profileSetup.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 4/9/23.
//

import SwiftUI

struct profileSetup: View {
    @State private var showAlert: Bool = false
    @State private var moveForward: Bool = false
    @State var selectedMajor = "Undecided 🤷‍♂️" // 2
    @State var bio: String = ""
    @State private var selectedAvatar: String? = nil
    let profilePictureAnimals = ["Llama", "Lion", "Panda", "Giraffe", "Elephant", "Koala", "Horse", "Dog", "Cat", "Butterfly", "Bee"]
    var token = UserDefaults.standard.string(forKey: "token") ?? ""
    
    func updateProfileInfo() async -> Bool {
        
        let urlString = "https://unifriendapi.onrender.com/personal_info?avatar=\(selectedAvatar?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&bio=\(bio.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
        
        print(urlString)
        guard let url = URL(string: urlString) else {
            // Handle invalid URL error
            print("invalid string")
            return false
        }
        
        // Create a GET request with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        _ = URLSession.shared
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return (String(data: data, encoding: .utf8) == "{\"message\":\"It worked!\",\"didWork\":true}")
        } catch {
            print("Error decoding JSON: \(error)")
            // Handle errors here
            return false
        }
        
    }
    
    
    var body: some View {
        
        ScrollView {
            VStack {
                NavigationLink(destination: ContentView(), isActive: $moveForward) { EmptyView() }
                HStack {
                    Text("Avatar")
                        .padding([.top, .leading, .trailing])
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(profilePictureAnimals.indices) { index in
                            Button(action: {
                                selectedAvatar = profilePictureAnimals[index]
                            }, label: {
                                Image(profilePictureAnimals[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90)
                                    .cornerRadius(90)
                                
                                    .background(Circle().foregroundColor(.white))
                                    .overlay(selectedAvatar == profilePictureAnimals[index] ? Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 25))
                                        .foregroundColor(.white)
                                             : nil)
                            })
                        }
                    }.padding(.horizontal)
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                
                .cornerRadius(10)
                .padding()
                
                
                
                
                
                VStack(alignment: .leading){
                    Text("Bio")
                    TextEditor(text: $bio)
                        .frame(width: 320, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .cornerRadius(10)
                        .fixedSize()
                    
                }.padding()
                Button("Update Account Info") {
                    if(selectedAvatar == "") {
                        showAlert = true
                        return
                    } else {
                        Task{
                            var success = await updateProfileInfo()
                            if success {
                                moveForward = true
                            } else {
                                showAlert = true
                                
                            }
                        }
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Account Setup")
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

struct profileSetup_Previews: PreviewProvider {
    static var previews: some View {
        profileSetup()
    }
}
