//
//  AppDelegate.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 29/04/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import Alamofire
import SwiftyJSON
import AudioToolbox

extension Notification.Name {
    static let webSocketConnecting = Notification.Name("org.mushare.tsukuba.webSocketConnecting")
    static let didWebSocketConnected = Notification.Name("org.mushare.tsukuba.didWebSocketConnected")
    static let didRoomStatusUpdated = Notification.Name("org.mushare.tsukuba.didRoomStatusUpdated")
    static let didReceiveNewChat = Notification.Name("org.mushare.tsukuba.didReceiveNewChat")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let config = Config.shared
    
    var isChatting = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        config.autoEnvironment()
        config.setupKingshifer()
        config.setupLanguage(Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0])
        // Set suitable columns for iPhone and iPad.
        config.setupColumns(UIScreen.main.bounds.size.width)

        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            print(userInfo)
        }
        
        // Avoid flash of the navigation bar when pushing a new view controller.
        window?.backgroundColor = .white

        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        SocketManager.shared.refreshSocket()
        SocketManager.shared.delegate = self
 
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait;
    }
    
    // MARK: - APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        config.deviceToken = deviceToken.hexString
        if DEBUG {
            NSLog("Device token from APNs server is %@.", config.deviceToken);
        }

        DeviceManager.shared.uploadDeviceToken(config.deviceToken) { (success) in
            if DEBUG {
                print("Device upload success = %@", success)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if DEBUG {
            NSLog("Received remote notification, userInfo = %@", userInfo);
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.fczm.Httper" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Tsukuba", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        if DEBUG {
            NSLog("SQLite file stores at \(url)")
        }
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            // Use lightweight migration mode.
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

extension AppDelegate: SocketManagerDelegate {
    
    func socketConecting() {
        NotificationCenter.default.post(name: .webSocketConnecting, object: self)
    }
    
    func scoketConnected() {
        NotificationCenter.default.post(name: .didWebSocketConnected, object: self)
    }
    
    func socketDisconnected() {
        
    }
    
    func didReceiveSocketMessage(_ chats: [Chat]) {
        if !isChatting {
            NotificationCenter.default.post(name: .didRoomStatusUpdated, object: self)
        }
        
        // Play a short sound and vibrate after receiving a chat message.
        if let soundUrl = R.file.didReceivedMessageWav() {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            
            AudioServicesPlaySystemSound(soundId)
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        NotificationCenter.default.post(name: .didReceiveNewChat, object: self, userInfo: [
            "chats": chats
        ])
    }
}
