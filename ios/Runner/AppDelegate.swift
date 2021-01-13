import UIKit
import Flutter
import flutter_downloader
import FolioReaderKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    let eub_kitty = FlutterMethodChannel(name: "epub_kitty", binaryMessenger: controller.binaryMessenger)
    
    eub_kitty.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        print(call.method)
        if(!controller.hasPlugin("EpubKittyPlugin")) {
            let dic: NSDictionary = call.arguments as! NSDictionary
            let strPath: String = dic.value(forKey: "bookPath") as! String
            print(strPath)
            openEPub(strPath: dic.value(forKey: "bookPath") as! String, conteroller: controller)
        }
    })
    
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}

private func openEPub(strPath: String, conteroller: UIViewController) {
    let config = FolioReaderConfig()
    //        let bookPath = Bundle.main.path(forResource: "For the Love of Rescue Dogs - Tom Colvin", ofType: "epub")
    let folioReader = FolioReader()
    folioReader.presentReader(parentViewController: conteroller, withEpubPath: strPath, andConfig: config)
}
