//
//  accountSetup.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 4/9/23.
//

import SwiftUI

struct accountSetup: View {
    
    func updateUniversityInfo() async -> Bool {

        let urlString = "https://unifriendapi.onrender.com/university_info?university=\(selectedUniversity.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&graduating_year=\(selectedGradYear)&major=\(selectedMajor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
        
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
    
    
    var token = UserDefaults.standard.string(forKey: "token") ?? ""
    let universityMajors = ["Undecided 🤷‍♂️", "Accounting 💰", "Anthropology 🧑‍🌾", "Architecture 🏛️", "Art 🎨", "Biology 🧬", "Business Administration 💼", "Chemistry 🔬", "Civil Engineering 🏗️", "Communications 📡", "Computer Science 💻", "Criminal Justice 🔒", "Economics 💸", "Education 🎓", "English 📚", "Environmental Science 🌱", "Finance 💳", "Foreign Languages 🗣️", "Geology 🌋", "Graphic Design 🎨", "History 📜", "Information Technology 🌐", "International Relations 🌎", "Journalism 📰", "Marketing 📈", "Mathematics ➗", "Mechanical Engineering 🚂", "Music 🎼", "Nursing 👩‍⚕️", "Philosophy 🤔", "Physics 🌠", "Political Science 🏛️", "Psychology 🧠", "Public Health 🏥", "Religious Studies 🙏", "Social Work 🤝", "Sociology 👥", "Theater 🎭", "Urban Planning 🏙️"]


    let graduatingYears = ["2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"]
    @State var selectedGradYear = "2023" // 2
    @State var selectedMajor = "Undecided 🤷‍♂️" // 2
    @State var selectedUniversity: String = ""
    @State private var showAlert: Bool = false
    @State private var moveForward: Bool = false

    var body: some View {
        ScrollView {
            NavigationLink(destination: ContentView(), isActive: $moveForward) { EmptyView() }
            VStack(alignment: .leading){
                Text("University")
                TextField("Enter your university", text: $selectedUniversity)
            }.padding()
            HStack{
                
                VStack(alignment: .leading){
                    
                    
                    Text("Graduating Year")
                    Picker("Pick a Graduating Year", selection: $selectedGradYear) { // 3
                        ForEach(graduatingYears, id: \.self) { item in // 4
                            Text(item) // 5
                        }
                    }
                }
                Spacer()
            }.padding()
            HStack{
                
                VStack(alignment: .leading){
                    
                    
                    Text("Major")
                        .padding([.top, .leading, .trailing])
                    Picker("Pick a major", selection: $selectedMajor) { // 3
                        ForEach(universityMajors, id: \.self) { item in // 4
                            Text(item) // 5
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Spacer()
            }
            
            Button("Update Account Info") {
                if(selectedUniversity == "") {
                    showAlert = true
                    return
                } else {
                    Task{
                        let success = await updateUniversityInfo()
                        if success {
                            moveForward = true
                        } else {
                            showAlert = true

                        }
                    }
                }
                print(token, selectedMajor, selectedGradYear, selectedUniversity)
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Selection"), message: Text("Please ensure you entered all required inputs"), dismissButton: .default(Text("Try Again")))
            }
        }
        .navigationBarTitle("Account Setup")
            
        .navigationBarBackButtonHidden(true)
    }
}

struct accountSetup_Previews: PreviewProvider {
    static var previews: some View {
        accountSetup()
    }
}
