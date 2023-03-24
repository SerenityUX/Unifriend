//
//  eventSelection.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 4/10/23.
//

import SwiftUI
import WrappingHStack

struct eventSelection: View {
    
    func addEvent(eventName: String) async {
            
        let urlString = "https://unifriendapi.onrender.com/add_event?&event=\(eventName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
            
            
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
    func removeEvent(eventName: String) async {
            
        let urlString = "https://unifriendapi.onrender.com/remove_event?&event=\(eventName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&auth_token=\(UserDefaults.standard.string(forKey: "token") ?? "")"
            
            
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
    

    
    
    @State var selectedEvents = [String]()
    let events = [
        Event(name: "Basketball", category: "Sports"),
        Event(name: "Football", category: "Sports"),
        Event(name: "Soccer", category: "Sports"),
        Event(name: "Volleyball", category: "Sports"),
        Event(name: "Ultimate Frisbee", category: "Sports"),
        Event(name: "Track and Field", category: "Sports"),
        Event(name: "Swim Meet", category: "Sports"),
        Event(name: "Tennis", category: "Sports"),
        Event(name: "Campout", category: "Outdoor Recreation"),
        Event(name: "Hiking", category: "Outdoor Recreation"),
        Event(name: "Rock Climbing", category: "Outdoor Recreation"),
        Event(name: "Kayaking", category: "Outdoor Recreation"),
        Event(name: "Ski", category: "Outdoor Recreation"),
        Event(name: "Snowboarding", category: "Outdoor Recreation"),
        Event(name: "Hackathon", category: "Technology"),
        Event(name: "Coding Competition", category: "Technology"),
        Event(name: "Robotics Workshop", category: "Technology"),
        Event(name: "Career Fair", category: "Career"),
        Event(name: "Job Interview", category: "Career"),
        Event(name: "Resume Review", category: "Career"),
        Event(name: "Internship Info", category: "Career"),
        Event(name: "Entrepreneurship", category: "Career"),
        Event(name: "Org Fair", category: "Student Life"),
        Event(name: "Club Rush", category: "Student Life"),
        Event(name: "Peer Mentoring", category: "Student Life"),
        Event(name: "Volunteer Fair", category: "Community Service"),
        Event(name: "Charity Walk/Run", category: "Community Service"),
        Event(name: "Habitat for Humanity", category: "Community Service"),
        Event(name: "Blood Drive", category: "Community Service"),
        Event(name: "Mental Health", category: "Health and Wellness"),
        Event(name: "Yoga", category: "Health and Wellness"),
        Event(name: "Healthy Eating", category: "Health and Wellness"),
        Event(name: "Meditation", category: "Health and Wellness"),
        Event(name: "Guest Speaker", category: "Education"),
        Event(name: "Research Symposium", category: "Education"),
        Event(name: "Science Fair", category: "Education"),
        Event(name: "Political Debate", category: "Politics"),
        Event(name: "Town Hall Meeting", category: "Politics"),
        Event(name: "Election Night", category: "Politics"),
        Event(name: "Cultural Festival", category: "Diversity"),
        Event(name: "International Food", category: "Food"),
        Event(name: "Wine and Cheese", category: "Food"),
        Event(name: "Beer Tasting", category: "Food"),
        Event(name: "Art Exhibition", category: "Art"),
        Event(name: "Dance Performance", category: "Art"),
        Event(name: "Musical Performance", category: "Art"),
        Event(name: "Movie Night", category: "Entertainment"),
        Event(name: "Comedy Show", category: "Entertainment"),
        Event(name: "Cafe", category: "Student Life")
    ]


    
    var body: some View {
        ScrollView {
            WrappingHStack(events) { event in

                    HStack {
                        
                        /*@START_MENU_TOKEN@*/Text(event.name)/*@END_MENU_TOKEN@*/

                        
                            .onTapGesture {
                                
                                if let index = selectedEvents.firstIndex(of: event.name) {
                                    selectedEvents.remove(at: index)
                                    Task {
                                        await removeEvent(eventName: event.name)
                                    }
                                    
                                } else {
                                    selectedEvents.append(event.name)
                                    Task {
                                        await addEvent(eventName: event.name)
                                    }
                                }
                            }
                        
                        selectedEvents.contains(event.name) ? (
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.body)

                        ) : (nil)
                    }

                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .foregroundColor(.white)
                    .background(selectedEvents.contains(event.name) ? Color.green : Color.gray)
                    .cornerRadius(20)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                
            }
                
            }
        .navigationTitle("Select Events")

        }

    
}

struct eventSelection_Previews: PreviewProvider {
    static var previews: some View {
        eventSelection()
    }
}


struct Event: Identifiable {
    var id = UUID()
    var name: String
    var category: String
    var selected: Bool = false
}

