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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let settings = PopupParams()
        let res = settings.parseSettings()
        
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

