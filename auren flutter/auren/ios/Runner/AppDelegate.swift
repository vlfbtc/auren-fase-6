import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Setup Google Maps
    GMSServices.provideAPIKey("AIzaSyDFNOL_Mq3jq4frMhXT8nquCl2JgWE6lvk")
    
    // Force enable local network privacy permissions for debug builds
    #if DEBUG
    if let url = URL(string: "http://localhost:8123") {
        URLSession.shared.dataTask(with: url).resume()
    }
    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
