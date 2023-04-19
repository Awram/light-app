import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.myapp/light_sensor"
  
  override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
  let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller
  }
}




