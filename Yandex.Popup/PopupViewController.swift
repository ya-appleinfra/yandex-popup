//
//  PopupViewController.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class PopupViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var iconMaxWidthConstrait: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var descLabel: NSTextField!
    
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var infoButton: NSButton!
    
    // input

    @IBOutlet weak var inputField: NSTextField?
    @IBOutlet weak var secureInputField: NSSecureTextField?
    
    // progress view
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator?
    @IBOutlet weak var progressCompletedImage: NSImageView?
    
    // qrcode
    
    @IBOutlet weak var qrCodeImageView: NSImageView!
    @IBOutlet weak var qrCodeLabel: NSTextField!
    
    // dropdown
    
    @IBOutlet weak var dropdownMenu: NSPopUpButton?
    
    
    let popupParams: PopupParams = PopupParams()

    var popupSettings: PopupSettings? = nil
    
    @objc private func applyConfig() {

        popupSettings = popupParams.parseSettings()
        
        let settings = popupSettings!
            
        if (settings.iconName != nil) {
            imageView.image = NSImage.init(named: settings.iconName!)
        }
        
        if (settings.iconPath != nil) {
            imageView.image = NSImage(contentsOfFile: settings.iconPath!)
        }
        
        if (settings.iconMaxWidth != 0) {
            iconMaxWidthConstrait.constant = CGFloat.init(integerLiteral: settings.iconMaxWidth!)
        }
        
        headerLabel.stringValue = settings.headerText!
        
        settings.descText!.addAttribute(NSAttributedString.Key.font, value: descLabel.font!, range: NSRange(location: 0, length: settings.descText!.length))
        settings.descText!.addAttribute(NSAttributedString.Key.foregroundColor, value: descLabel.textColor!, range: NSRange(location: 0, length: settings.descText!.length))
        descLabel.attributedStringValue =  settings.descText!
        
        okButton.title = settings.okButtonText!
        if settings.okButtonEnabled == 0 {
            okButton.isHidden = true
        }else{
            okButton.isHidden = false
        }
        
        actionButton.title = settings.actionButtonText!
        if settings.actionButton != 0 {
            actionButton.isHidden = false
        }else{
            actionButton.isHidden = true
        }
        
        infoButton.title = settings.infoButtonText!
        if settings.infoButtonEnabled != 0 {
            infoButton.isHidden = false
        } else {
            infoButton.isHidden = true
        }
        
        
        
        // input
        
        inputField?.stringValue = settings.inputText!
        secureInputField?.stringValue = settings.inputText!
        inputField?.placeholderString = settings.inputPlaceholder!
        secureInputField?.placeholderString = settings.inputPlaceholder!
        
        if settings.inputSecure == 1 {
            secureInputField?.isHidden = false
            inputField?.isHidden = true
        }else{
            secureInputField?.isHidden = true
            inputField?.isHidden = false
        }
        
        // progress
        
        progressCompletedImage?.isHidden = true
        switch settings.progressType {
            case "bar":
                progressIndicator?.style = .bar
            case "spinner":
                progressIndicator?.style = .spinning
            case "completed":
                progressIndicator?.isHidden = true
                progressCompletedImage?.isHidden = false
            default:
                progressIndicator?.style = .bar
        }
        
        progressIndicator?.startAnimation(self)
        
        // qrcode
        
        if settings.type == "qrcode" {
    
            if settings.qrCodeLabel == 0 {
                qrCodeLabel.isHidden = true
            }else{
                qrCodeLabel.stringValue  = settings.qrCodeLabelText!
                qrCodeLabel.font = NSFont.labelFont(ofSize: CGFloat(settings.qrCodeLabelTextSize!))
            }
            
            let qrdata = settings.qrCodeString!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            let qrfilter = CIFilter(name: "CIQRCodeGenerator")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            qrfilter?.setValue(qrdata, forKey: "inputMessage")
            qrfilter?.setValue("H", forKey: "inputCorrectionLevel")
            
            let qrcodeImage: CIImage! = qrfilter!.outputImage
            let rep = NSCIImageRep(ciImage: qrcodeImage.transformed(by: transform))
            let nsImage = NSImage(size: rep.size)
            nsImage.addRepresentation(rep)

            qrCodeImageView.image = nsImage
        }
        
        // dropdown
        if settings.type == "dropdown" {
            dropdownMenu?.removeAllItems()
            dropdownMenu?.addItems(withTitles: settings.dropdownItems!.components(separatedBy: ", "))
            dropdownMenu?.select(dropdownMenu?.item(withTitle: settings.dropdownDefault!))
            dropdownMenu?.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadConfigNotification), name: Notification.Name("ReloadConfig"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(processOAuthCallback), name: Notification.Name("OAuthCallbackRecieved"), object: nil)
        
        self.applyConfig()
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        
        let settings = popupSettings!

        switch settings.windowFocusElement {

                case "input":
                    self.view.window?.makeFirstResponder(inputField)

                case "okbutton":
                    self.view.window?.makeFirstResponder(okButton)

                case "actionbutton":
                    self.view.window?.makeFirstResponder(actionButton)

                default:
                    
                    if (settings.type == "input") {
                        
                        if (settings.inputSecure == 1) {
                            self.view.window?.makeFirstResponder(secureInputField)
                        }else{
                            self.view.window?.makeFirstResponder(inputField)
                        }
                        
                    }else{
                        self.view.window?.makeFirstResponder(nil)
                    }

            }
        
    }

    @IBAction func actionPushed(sender: Any) {
        
        let settings = popupSettings!
        
        let actions = settings.actionButtonActions!.components(separatedBy: "|")
        
        for action in actions {
        
            let actionComponents = action.components(separatedBy: "#")
        
            switch actionComponents[0] {
            
            case "launch":
                NSWorkspace.shared.launchApplication(actionComponents[1])
            case "open":
                NSWorkspace.shared.openFile(actionComponents[1])
            case "open_url":
                NSWorkspace.shared.open(URL(string: actionComponents[1])!)
            case "exit":
                NSApp.terminate(self)
            case "exit_err":
                exit(1)
            default:
                NSApp.terminate(self)
            }
            
        }
    }
    
    @IBAction func okPushed(sender: Any) {
        let settings = popupSettings!
        
        let actions = settings.okButtonActions!.components(separatedBy: "|")
        
        if settings.processOauthCallback == 1 && settings.exitOnOauthCallback == 0 {
            if let provider = NSApplication.shared.delegate as? InputProvider {
                provider.printToken()
            }
        }
        
        for action in actions {
        
            let actionComponents = action.components(separatedBy: "#")
        
            switch actionComponents[0] {
            
            case "launch":
                NSWorkspace.shared.launchApplication(actionComponents[1])
            case "open":
                NSWorkspace.shared.openFile(actionComponents[1])
            case "open_url":
                NSWorkspace.shared.open(URL(string: actionComponents[1])!)
            case "exit":
                NSApp.terminate(self)
            case "exit_err":
                exit(1)
            default:
                NSApp.terminate(self)
            }
            
        }
    }
    
    @IBAction func infoButtonPushed(sender: Any) {
        
        let settings = popupSettings!
        
        let actions = settings.infoButtonActions!.components(separatedBy: "|")
        
        for action in actions {
        
            let actionComponents = action.components(separatedBy: "#")
        
            switch actionComponents[0] {
            
            case "launch":
                NSWorkspace.shared.launchApplication(actionComponents[1])
            case "open":
                NSWorkspace.shared.openFile(actionComponents[1])
            case "open_url":
                NSWorkspace.shared.open(URL(string: actionComponents[1])!)
            case "exit":
                NSApp.terminate(self)
            case "exit_err":
                exit(1)
            default:
                NSApp.terminate(self)
            }
            
        }
    }
    
    @objc func reloadConfigNotification() {
        self.performSelector(onMainThread: #selector(applyConfig), with: nil, waitUntilDone: false)
    }
    
    @objc func processOAuthCallback() {
        let settings = popupSettings!
        guard popupSettings?.processOauthCallback == 1 else { return }
        if let provider = NSApplication.shared.delegate as? InputProvider,
           settings.exitOnOauthCallback == 1 {
            provider.printToken()
            NSApp.terminate(self)
        }
    }
    
}
