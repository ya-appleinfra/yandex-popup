//
//  NCFallbackViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Cocoa
import Foundation

class NCFallbackViewController: NSViewController {

    public var popupSettings: PopupSettings?
    
    
    @IBOutlet weak var Icon: NSImageView!
    
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var messageLabel: NSTextField!
    @IBOutlet weak var actionButtonView: NSView!
    @IBOutlet weak var actionButton: NSButton!
    
    @IBOutlet weak var mouseTrackingView: MouseTrackingView!
    
    override func viewDidLoad() {

        actionButtonView.isHidden = true
        actionButtonView.alphaValue = 0
        
        mouseTrackingView.active = false
    
        var headerLabelText: String
        var messageLabelText: String
        
        if (popupSettings?.notificationTitle != "" && popupSettings?.notificationSubtitle != "" && popupSettings?.notificationBody != "") {
            headerLabelText = (popupSettings?.notificationSubtitle != "") ? (popupSettings!.notificationTitle! + "\n" + popupSettings!.notificationSubtitle!) : popupSettings!.notificationTitle!
            messageLabelText = popupSettings!.notificationBody!
        }else{
            headerLabelText = popupSettings!.notificationTitle!
            messageLabelText = (popupSettings?.notificationSubtitle != "") ? popupSettings!.notificationSubtitle! : popupSettings!.notificationBody!
        }
        
        headerLabel.stringValue = headerLabelText
        messageLabel.stringValue = messageLabelText
        
            if (popupSettings?.notificationButton == 1 || popupSettings?.notificationButtonText != "" ) {
            actionButtonView.isHidden = false
            mouseTrackingView.active = true
        }
        
        actionButton.title = popupSettings!.notificationButtonText!
        
        if (popupSettings!.iconName != nil) {
            Icon.image = NSImage.init(named: popupSettings!.iconName!)
        }
        
        if (popupSettings!.iconPath != nil) {
            Icon.image = NSImage(contentsOfFile: popupSettings!.iconPath!)
        }
    }
    
    @IBAction func notificationClicked(sender: Any) {
        
        switch popupSettings?.notificationActionType {
            case "launch":
            NSWorkspace.shared.launchApplication(popupSettings!.notificationActionTarget!)
                NSApp.terminate(self)
            case "open":
                NSWorkspace.shared.openFile(popupSettings!.notificationActionTarget!)
                NSApp.terminate(self)
            case "open_url":
                NSWorkspace.shared.open(URL(string: popupSettings!.notificationActionTarget!)!)
                NSApp.terminate(self)
            case .none:
                NSApp.terminate(self)
            case .some(_):
                NSApp.terminate(self)
        }
        
    }
    
}
