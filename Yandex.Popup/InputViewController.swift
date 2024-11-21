//
//  InputViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class InputViewController: PopupViewController {
    
    var input = [String: String]()
    
    @objc override func processOAuthCallback() {
        let settings = popupSettings!
        guard settings.processOauthCallback == 1 else { return }
        
        guard let provider = NSApplication.shared.delegate as? InputProvider else { return }
        if (settings.inputSecure == 1), (settings.inputSecureSetToOauth == 1) {
            secureInputField?.stringValue = provider.getToken() ?? ""
        } else {
            input["access_token"] = provider.getToken() ?? ""
        }
        if settings.exitOnOauthCallback == 1 {
            okPushed(sender: self)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if Int(obj.userInfo!["NSTextMovement"] as! Int) == NSReturnTextMovement {
            okPushed(sender: self)
        }
    }
    
    @IBAction override func okPushed(sender: Any) {
        
        var value: String!
        if popupParams.parseSettings().inputSecure == 0 {
            value = inputField?.stringValue
        }else{
            value = secureInputField?.stringValue
        }
        
        input["input"] = value
        
        do {
            // Serialize to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: input)
            
            // Convert to a string and print
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                
                let stderr = FileHandle.standardOutput
                stderr.write( JSONString.data(using: .utf8)! )
                
                NSApp.terminate(self)
            }
        } catch {
            ()
        }
        
    }
    
}
