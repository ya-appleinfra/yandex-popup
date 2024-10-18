//
//  DropDownViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class DropDownViewController: PopupViewController {
    
    
    
    @IBAction override func okPushed(sender: Any) {
        var selected = ""
        if let selectedValue = dropdownMenu?.selectedItem?.title {
            selected = selectedValue
        }

        let output: [String: String] = [
            "selected": selected
        ]

        do {
            // Serialize to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: output)

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
