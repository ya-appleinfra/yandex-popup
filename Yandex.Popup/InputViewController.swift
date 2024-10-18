//
//  InputViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class InputViewController: PopupViewController {
    
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
        
        let input: [String: String] = [
            "input": value
        ]

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
