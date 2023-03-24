//
//  signup.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 3/25/23.
//

import SwiftUI
import iPhoneNumberField
import Alamofire


struct login: View {
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State var validAuth = false
    
    func createAccount() {
        
        if let url = URL(string: "https://unifriendapi.onrender.com/login?password=\(password)&phone_number=\(phone.filter { !" ()- ".contains($0) })") {
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
    
    @State var phone: String = ""
    @State var password: String = ""
    var body: some View {
        NavigationLink(destination: ContentView(), isActive: $validAuth) { EmptyView() }

        VStack {

            VStack {
                Text("Let's Get You Logged In")

                iPhoneNumberField("Phone", text: $phone)
                    .flagHidden(false)
                    .flagSelectable(true)
                    .padding()
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                

                    
                Button {
                    Task {
                        //Stores the URL as a URL
                        createAccount()
                    }
                } label: {
                    Text("Login")
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Invalid Credentials"), message: Text(errorMessage), dismissButton: .default(Text("Try Again")))
                }
                    
            }
        }.navigationBarTitle("Login")
        .navigationBarHidden(false)
    }
}

struct login_Previews: PreviewProvider {
    static var previews: some View {
        login()
    }
}


