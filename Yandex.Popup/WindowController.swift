//
//  WindowController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    
    let popupParams: PopupParams = PopupParams()
    
    @objc private func applyConfig(resetWindow: Bool = false) {
        let res = popupParams.parseSettings()
        
        // window controls
        
        window?.isRestorable = false
        
        if (res.windowControls! & 1) == 0 { self.window!.styleMask.remove(.closable) }
        if (res.windowControls! & 2) == 0 { self.window!.styleMask.remove(.miniaturizable) }
        if (res.windowControls! & 4) == 0 { self.window!.styleMask.remove(.resizable) }
        if (res.windowControls! & 8) == 0 {
            for item:NSMenuItem in NSApp.mainMenu!.items {
                if item.identifier!.rawValue != "edit" {
                    item.isHidden = true
                }
            }
        }

        // title
        
        self.window?.title = res.titleText!
        
        if res.titleEnabled == 0 { self.window?.titleVisibility = .hidden }
        
        // window desktop spaces

        if res.windowAllSpaces == 1 {
            self.window?.collectionBehavior.insert(.canJoinAllSpaces)
        }else{
            self.window?.collectionBehavior.remove(.canJoinAllSpaces)
        }
        
        if resetWindow || res.resetWindow == 1 {
        
            // window size
            
            if res.width != nil && res.height != nil {
                self.window?.setFrame(NSMakeRect(0, 0, CGFloat(res.width!), CGFloat(res.height!)), display: true)
            }
            
            // window position
            
            if res.position != nil {
                
                let screenSizeRect = self.window?.screen?.visibleFrame
                var offsetX: CGFloat = 0
                var offsetY: CGFloat = 0
                
                switch res.position {
                case "center":
                    
                    offsetX = screenSizeRect!.midX - ((self.window?.frame.width)! / 2)
                    offsetY = screenSizeRect!.midY - ((self.window?.frame.height)! / 2)

                case "left-top":
                    
                    offsetX = (screenSizeRect!.minX + CGFloat(screenSizeRect!.maxX / 20))
                    offsetY = screenSizeRect!.maxY - (self.window?.frame.height)! - (screenSizeRect!.maxY / 20)
                
                case "left-bottom":
                    
                    offsetX = (screenSizeRect!.minX + CGFloat(screenSizeRect!.maxX / 20))
                    offsetY = screenSizeRect!.minY + (screenSizeRect!.maxY / 20)
                
                case "right-top":
                    
                    offsetX = screenSizeRect!.maxX - (self.window?.frame.width)! - (screenSizeRect!.maxX / 20)
                    offsetY = screenSizeRect!.maxY - (self.window?.frame.height)! - (screenSizeRect!.maxY / 20)
                
                case "right-bottom":
                    
                    offsetX = screenSizeRect!.maxX - (self.window?.frame.width)! - (screenSizeRect!.maxX / 20)
                    offsetY = screenSizeRect!.minY + (screenSizeRect!.maxY / 20)

                default:
                    
                    offsetX = screenSizeRect!.midX - ((self.window?.frame.width)! / 2)
                    offsetY = screenSizeRect!.midY - ((self.window?.frame.height)! / 2)
                }
                
                self.window?.setFrameOrigin(NSPoint(x: offsetX, y:offsetY))
            }else{
                
                if res.position_x != nil && res.position_y != nil {
                    let offsetX = CGFloat(res.position_x!)
                    let offsetY = CGFloat(res.position_y!)
                    
                    self.window?.setFrameOrigin(NSPoint(x: offsetX, y:offsetY))
                }
                
            }
            
        }
        
        // floating
        
        if res.floating == 1 { self.window?.level = .floating }
    }
    
    override func windowDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadConfigNotification), name: Notification.Name("ReloadConfig"), object: nil)
        
        self.applyConfig(resetWindow: true)
        super.windowDidLoad()
    }
    
    @objc func reloadConfigNotification() {
        self.performSelector(onMainThread: #selector(applyConfig), with: nil, waitUntilDone: false)
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(self)
    }
    
}
