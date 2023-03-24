//
//  signup.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 3/25/23.
//

import SwiftUI
import iPhoneNumberField
import Alamofire


struct signup: View {
    @State private var showAlert = false
    @State private var errorMessage = ""
    //Should be false
    @State var validAuth = false

    func createAccount() {
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            // Unable to encode the name string
            showAlert = true
            errorMessage = "Invalid Characters Used"
            return
        }
        if let url = URL(string: "https://unifriendapi.onrender.com/signup?password=\(password)&name=\(encodedName)&phone_number=\(String(phone.filter { !" ()-".contains($0) }))") {
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
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let responseDictionary = json as? [String: Any] {
                                let auth = responseDictionary["auth"] as? Bool ?? false
                                let message = responseDictionary["message"] as? String ?? ""
                                let authToken = responseDictionary["auth_token"] as? String ?? ""
                                print("Auth: \(auth), Message: \(message), Auth Token: \(authToken)")
                                errorMessage = message
                                if (!auth) {
                                    
                                    self.showAlert = true
                                } else {
                                    UserDefaults.standard.set(authToken, forKey: "token")

                                
                                    validAuth = true
                                }
                            }
                        } catch {
                            print("Error parsing response JSON: \(error)")
                        }
                    } else {
                        // Handle error response
                    }
                }
            }
            task.resume()
        } else {
            self.showAlert = true
            errorMessage = "Invalid Characters Used"
        }


    }
    
    @State private var name: String = ""
    @State var phone: String = ""
    @State var password: String = ""
    var body: some View {
        NavigationLink(destination: accountSetup(), isActive: $validAuth) { EmptyView() }
//Should be $validAuth, temporarily true
        VStack {

            VStack {
                Text("Let's Get You Signed Up")
                TextField("Name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                iPhoneNumberField("Phone", text: $phone)            .flagHidden(false)
                    .flagSelectable(true)
                    .padding()
                    
                Button {
                    Task {
                        //Stores the URL as a URL
                        createAccount()
                    }
                } label: {
                    Text("Signup")
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Invalid Credentials"), message: Text(errorMessage), dismissButton: .default(Text("Try Again")))
                }
                    
            }
        }.navigationBarTitle("Signup")
    }
}

struct signup_Previews: PreviewProvider {
    static var previews: some View {
        signup()
    }
}

struct Auth: Codable {
    var message: String
    var auth: Bool
    var auth_token: String?
}

