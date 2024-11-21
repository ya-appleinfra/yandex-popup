//
//  DropDownViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class DropDownViewController: PopupViewController {
    var selected = ""
    var output = [String: String]()
    
    @objc override func processOAuthCallback() {
        let settings = popupSettings!
        guard settings.processOauthCallback == 1 else { return }
        
        guard let provider = NSApplication.shared.delegate as? InputProvider else { return }
        
        output["access_token"] = provider.getToken() ?? ""
        
        if settings.exitOnOauthCallback == 1 {
            okPushed(sender: self)
        }
    }
    
    @IBAction override func okPushed(sender: Any) {
        
        if let selectedValue = dropdownMenu?.selectedItem?.title {
            selected = selectedValue
        }

        output["selected"] = selected

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
