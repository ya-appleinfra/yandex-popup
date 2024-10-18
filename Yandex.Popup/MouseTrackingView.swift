//
//  MouseTrackingView.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Cocoa
import QuartzCore

class MouseTrackingView: NSControl {
    
    private var trackingArea: NSTrackingArea?
    
    public var active: Bool = false
    
    @IBOutlet weak var buttonView: NSView?
    @IBOutlet weak var textView: FadingView?
    
    override func layout() {
        super.layout()
        self.layer?.frame = self.bounds
        updateTrackingAreas()
    }

    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        setupTrackingArea()
    }

    override func mouseEntered(with event: NSEvent) {
        
        if active {
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                buttonView?.animator().alphaValue = 1.0
            }
            
            textView?.fadeIn()
        }
    }

    override func mouseExited(with event: NSEvent) {
        
        if active {
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                buttonView?.animator().alphaValue = 0.0
            }
            
            textView?.fadeOut()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
        self.sendAction(self.action, to: self.target)
    }
    
    
    
}
