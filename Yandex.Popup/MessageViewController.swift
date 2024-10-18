//
//  MessageViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.


import Foundation
import Cocoa

class MessageViewController: PopupViewController {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        okPushed(sender: self)
    }

}
