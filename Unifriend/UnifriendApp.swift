
import SwiftUI
import OneSignal

@main
struct UnifriendApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                
                ContentView()
                    .accentColor(Color(#colorLiteral(red: 0.2509803922, green: 0.6156862745, blue: 0.3333333333, alpha: 1)))
            }
            .accentColor(Color(#colorLiteral(red: 0.2509803922, green: 0.6156862745, blue: 0.3333333333, alpha: 1)))

            }


    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // Remove this method to stop OneSignal Debugging
       OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
       OneSignal.initWithLaunchOptions(launchOptions)
    
       OneSignal.setAppId("8ec997e8-8f98-4943-95e5-b09df10e0138")
        
       OneSignal.promptForPushNotifications(userResponse: { accepted in
         print("User accepted notification: \(accepted)")
        
       })
      
        
      
      
       return true
    }
}


