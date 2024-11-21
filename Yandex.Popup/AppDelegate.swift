//
//  AppDelegate.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa
import Dispatch

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var sigSource: DispatchSourceSignal!
    var res: PopupSettings!
    var oauthCallbackToken: String? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let settings = PopupParams()
        self.res = settings.parseSettings()
        
        // signals
        
        signal(SIGUSR1, SIG_IGN) //ignoring signal response
        
        sigSource = DispatchSource.makeSignalSource(signal: SIGUSR1)
        sigSource.setEventHandler {
            NotificationCenter.default.post(name: Notification.Name("ReloadConfig"), object: self, userInfo: nil)
        }
        sigSource.resume()
        
        // activate
        
        if res.hideDock == 0 {
            NSApp.setActivationPolicy(.regular)
        }
        
        NSApp.activate(ignoringOtherApps: true)
        
        // pid
        
        struct StandardErrorOutputStream: TextOutputStream {
            let stderr = FileHandle.standardError
            
            func write(_ string: String) {
                guard let data = string.data(using: .utf8) else {
                    return // encoding failure
                }
                stderr.write(data)
            }
        }
        
        if res.pidFile!.count > 0 {
            let pid = getpid()
            let pidString = "\(pid)"
            
            do {
                try pidString.write(to: URL(fileURLWithPath: res.pidFile!), atomically: true, encoding: .utf8)
            } catch let error {
                
                var errStream = StandardErrorOutputStream()
                print("\(error)", to: &errStream)
                
            }
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

// Custom URL scheme support

extension AppDelegate: InputProvider {
    
    
    func getToken() -> String? {
        guard res.processOauthCallback == 1 else { return nil }
        return self.oauthCallbackToken
    }
    
    func printToken() {
        
        let output: [String: String] = [
            "token": oauthCallbackToken ?? ""
        ]
        
        do {
            // Serialize to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: output)
            
            // Convert to a string and print
            if let JSONStringData = String(data: jsonData, encoding: String.Encoding.utf8)?.data(using: .utf8) {
                
                let stdout = FileHandle.standardOutput
                stdout.write( JSONStringData )
            }
        } catch {
            print(error)
        }
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        
        guard let url = urls.first else {
            print("No URLs found")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let action = components.host else {
            print("Invalid URL or query parameters")
            return
        }
        
        switch action {
        case "refresh":
            NotificationCenter.default.post(name: Notification.Name("ReloadConfig"), object: self, userInfo: nil)
            return
        case "oauth_callback":
            guard res.processOauthCallback == 1 else { return }
            if let fragment = components.fragment {
                var tempComponents = URLComponents()
                tempComponents.query = fragment
                if let queryItems = tempComponents.queryItems {
                    self.oauthCallbackToken = queryItems.first(where: { $0.name == "access_token" })?.value
                }
            }
            NotificationCenter.default.post(name: Notification.Name("OAuthCallbackRecieved"), object: self, userInfo: nil)
        default:
            return
        }
    }
}

protocol InputProvider {
    func getToken() -> String?
    func printToken()
}

