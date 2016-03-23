//
//  AppDelegate.swift
//  SwiftySensorsExample
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Customize what services you want to scan for
        SensorManager.instance.setServicesToScanFor([
            CyclingPowerService.self,
            CyclingSpeedCadenceService.self,
            HeartRateService.self])
        
        // Add additional services we want to have access to (but don't want to specifically scan for)
        SensorManager.instance.addServiceTypes([DeviceInformationService.self])
        
        // Set the scan mode (see documentation)
        SensorManager.instance.scanMode = .Aggressive
        
        // Capture SwiftySensors log messages and print them to the console. You can inject your own logging system here if desired.
        SensorManager.onLogMessage.listen(self) { message in
            print(message)
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
}
