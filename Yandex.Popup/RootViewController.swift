//
//  ViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Cocoa
import UserNotifications

class RootViewController: NSViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var containerView: NSView!
    
    let popupParams: PopupParams = PopupParams()

    // notification center delegate
    
    @available(macOS 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.alert])
            NSApp.terminate(self)
        }

    @available(macOS 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        let action_type:String! = userInfo["action_type"] as? String
        let action_target:String! = userInfo["action_target"] as? String
        switch action_type {
        
        case "launch":
            NSWorkspace.shared.launchApplication(action_target)
            NSApp.terminate(self)
        case "open":
            NSWorkspace.shared.openFile(action_target)
            NSApp.terminate(self)
        case "open_url":
            NSWorkspace.shared.open(URL(string: action_target)!)
            NSApp.terminate(self)
        case .none:
            NSApp.terminate(self)
        case .some(_):
            NSApp.terminate(self)
        }
        
        completionHandler()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var settings: PopupSettings = popupParams.parseSettings()
        
        // notifications delegate
        
        if #available(macOS 10.14, *) {
            
            let center = UNUserNotificationCenter.current()
            
            center.delegate = self
            
            if (settings.type == "notification") {
                
                // checking notification mode

                if settings.notificationFallbackMode == "forced" {

                    // we are forced to use "legacy method"
                    self.showFallbackNC()

                }else{

                    // checking authorization
                    center.requestAuthorization(options: [.alert, .criticalAlert, .badge, .sound]) { (granted, error) in
                        if !granted {
                            settings.notificationCritical = 0
                            print("warning: critical alerts are not allowed. Switching to basic alerts")
                            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                                if !granted {
                                    
                                    print("error: request notification permission failed")

                                    if settings.notificationFallbackMode! != "allowed" {
                                        
                                        if settings.notificationErrorOnPermission == 0 {
                                            exit(0)
                                        }else{
                                            exit(1)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }

                    // here
                    center.getNotificationSettings { nSettings in
                       
                        if nSettings.authorizationStatus == .authorized && nSettings.alertSetting == .enabled {
                            
                            // if alert granted - showing
                            
                            let nAction = UNNotificationAction(identifier: "BUTTON_ACTION",
                                                               title: settings.notificationButtonText!,
                                                               options: [])
                            
                            var nActions: [UNNotificationAction] = []
                            
                            if (settings.notificationType != "alert") {
                                nActions = [nAction]
                            }
                            
                            let category = UNNotificationCategory(identifier: settings.notificationType!, actions: nActions, intentIdentifiers: [])
                            
                            center.setNotificationCategories([category])
                            
                            let cont = UNMutableNotificationContent()
                            
                            cont.title = settings.notificationTitle!
                            cont.subtitle = settings.notificationSubtitle!
                            cont.body = settings.notificationBody!
                            if settings.notificationCritical == 1 {
                                cont.sound = .defaultCritical
                            }
                            if settings.notificationThreadId == "random" {
                                cont.threadIdentifier = UUID().uuidString
                            } else {
                                cont.threadIdentifier = settings.notificationThreadId!
                            }
                            
                            cont.userInfo = [
                                "type"          : settings.notificationType!,
                                "action_type"   : settings.notificationActionType ?? "",
                                "action_target" : settings.notificationActionTarget!
                            ]
                            
                            cont.categoryIdentifier = settings.notificationType!
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: cont, trigger: trigger)
                            
                            center.add(request)
                            
                            DispatchQueue.main.sync {
                                NSApp.terminate(self)
                            }
                            
                        } else {
                            
                            print("error: notification permission not granted")

                            if settings.notificationFallbackMode! == "allowed" {
                                self.showFallbackNC()
                            }else{
                                if settings.notificationErrorOnPermission == 0 {
                                    exit(0)
                                }else{
                                    exit(1)
                                }
                            }

                        }
                    }
                }
                
                self.view.isHidden = true
            }
        }
        
        if (settings.type != "notification") {
            
            let view_identifier = settings.type! + "_view"
            
            let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: view_identifier) as! NSViewController
            
            addChild(controller)
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(controller.view)

            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                controller.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0)
            ])
        
        }

    }
    
    func showFallbackNC() {
        
        let settings: PopupSettings = popupParams.parseSettings()
        
        DispatchQueue.main.async {
            
            self.view.window?.orderOut(self)
            
            let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "nc_fallback_view") as! NCFallbackViewController
            
            self.addChild(controller)
            
            controller.popupSettings = settings
            
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 345, height: 110),
                styleMask: [.titled, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            
            // Configure panel appearance
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.styleMask = [.titled, .fullSizeContentView]
            panel.hasShadow = true
            panel.isOpaque = false
            panel.appearanceSource = self.view.window
            panel.alphaValue = 0.0 // Start invisible
            panel.collectionBehavior.insert(.canJoinAllSpaces)
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            panel.contentView?.addSubview(controller.view)
            
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: panel.contentView!.leadingAnchor, constant: 0),
                controller.view.trailingAnchor.constraint(equalTo: panel.contentView!.trailingAnchor, constant: 0),
                controller.view.topAnchor.constraint(equalTo: panel.contentView!.topAnchor, constant: 0),
                controller.view.bottomAnchor.constraint(equalTo: panel.contentView!.bottomAnchor, constant: -0)
            ])
            
            // Position the panel
            if let screen = NSScreen.main {
                let screenRect = screen.frame
                let panelRect = panel.frame
                
                switch settings.notificationFallbackPositionOrigin {
                case "top-left":
                    panel.setFrameOrigin(NSPoint(x: screenRect.minX + CGFloat(settings.notificationFallbackPaddingX!), y: screenRect.maxY - panelRect.height - 40 - CGFloat(settings.notificationFallbackPaddingY!)))
                case "bottom-left":
                    panel.setFrameOrigin(NSPoint(x: screenRect.minX + CGFloat(settings.notificationFallbackPaddingX!), y: screenRect.minY + CGFloat(settings.notificationFallbackPaddingY!)))
                case "bottom-right":
                    panel.setFrameOrigin(NSPoint(x: screenRect.maxX - panelRect.width - CGFloat(settings.notificationFallbackPaddingX!), y: screenRect.minY + CGFloat(settings.notificationFallbackPaddingY!)))
                default:
                    //top-right
                    panel.setFrameOrigin(NSPoint(x: screenRect.maxX - panelRect.width - CGFloat(settings.notificationFallbackPaddingX!), y: screenRect.maxY - panelRect.height - 40 - CGFloat(settings.notificationFallbackPaddingY!)))
                }
            }
            
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                panel.animator().alphaValue = 1.0
            }) {
                
                // Automatically close the panel after 3 seconds with fade-out effect
                
                //            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                //                NSAnimationContext.runAnimationGroup({ context in
                //                    context.duration = 0.5
                //                    panel.animator().alphaValue = 0.0
                //                }) {
                //                    panel.close()
                //                }
                //            }
                
            }
            
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

