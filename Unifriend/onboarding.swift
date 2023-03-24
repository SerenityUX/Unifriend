//
//  onboarding.swift
//  Unifriend
//
//  Created by Thomas Stubblefield on 3/25/23.
//

import SwiftUI

struct onboarding: View {
    var body: some View {
        NavigationView {
            
            VStack{
                Text("Time to Get You Setup")
                
                NavigationLink(destination: login()) {
                    Text("Portal to Login")
                }
                NavigationLink(destination: signup()) {
                    Text("Portal to Signup")
                }
            }

        }   .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

struct onboarding_Previews: PreviewProvider {
    static var previews: some View {
        onboarding()
    }
}
