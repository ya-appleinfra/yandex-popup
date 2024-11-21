//
//  Params.swift
//  Yandex.Popup
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

struct PopupSettings {
    
    // sytem-related
    
    var pidFile: String?
    var confFile: String?
    
    // window-related
    
    var resetWindow: Int?
    
    var windowAllSpaces: Int?
    var windowControls: Int?
    
    var windowFocusElement: String?
    
    var titleText: String?
    var titleEnabled: Int?
    
    var position: String?
    var position_x: Int?
    var position_y: Int?
    var width: Int?
    var height: Int?
    
    var floating: Int?
    
    // type
    
    var type: String?
    
    // generic content
    
    var iconName: String?
    var iconPath: String?
    var iconMaxWidth: Int?
    
    var headerText: String?
    var descText: NSMutableAttributedString?
    var okButtonEnabled: Int?
    var okButtonText: String?
    var descLinksDetect: Int?
    var descLinks: String?
    
    var actionButton: Int?
    var actionButtonActions: String?
    var actionButtonText: String?
    
    var exitOnOauthCallback: Int?
    
    // notification
    
    var notificationType: String?
    var notificationTitle: String?
    var notificationSubtitle: String?
    var notificationBody: String?
    var notificationButton: Int?
    var notificationButtonText: String?
    var notificationActionType: String?
    var notificationActionTarget: String?
    var notificationCritical: Int?
    var notificationThreadId: String?
    var notificationFallbackMode: String?
    var notificationErrorOnPermission: Int?
    var notificationFallbackPositionOrigin: String?
    var notificationFallbackPaddingX: Int?
    var notificationFallbackPaddingY: Int?
    
    // input specific
    
    var inputText: String?
    var inputPlaceholder: String?
    var inputSecure: Int?
    var inputSecureSetToOauth: Int?
    var hideDock: Int?
    
    // progress
    
    var progressType: String?
    
    // qrcode
    
    var qrCodeString: String?
    var qrCodeLabel: Int?
    var qrCodeLabelText: String?
    var qrCodeLabelTextSize: Int?
    
    
    // file specific
    
    var fileMode: String?
    var fileType: String?
    var fileExtension: String?
    var fileDestination: String?
    var fileReplace: Int?
    
    // dropdown specific
    var dropdownItems: String?
    var dropdownDefault: String?
    
    // OAuth callback
    var processOauthCallback: Int?
}

class PopupParams {
    
    private var dictConf: Dictionary<String, Any>?
    
    public func parseSettings() -> PopupSettings {
        
        if let jsonConfPath = ProcessInfo.processInfo.environment["YA_POPUP_CONF_FILE"] {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: jsonConfPath), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                dictConf = jsonResult as? Dictionary<String, Any>
            }catch{
                let stderr = FileHandle.standardOutput
                stderr.write(error.localizedDescription.data(using: .utf8)!)
            }
        }
        
        let kwargs = ArgumentParser(into: PopupSettings())
        
        // system
        
        kwargs.addArgument("--pid-file", \.pidFile,
                           category: .global, help: "System app pid file, path",
                           parser: { String($0) })
        
        // window
        
        kwargs.addArgument("--window-reset", \.resetWindow,
                           category: .window, 
                           help: "Reset window position and size metrics, int [0/1], default is 0",
                           parser: { Int($0) })
        
        kwargs.addArgument("--window-all-spaces", \.windowAllSpaces,
                           category: .window, 
                           help: "Show window on all spaces, int [0/1], default is 0",
                           parser: { Int($0) })
        
        kwargs.addArgument("--window-title", \.titleEnabled,
                           category: .window,
                           help: "Window title visibility, int [0/1], default is 1",
                           parser: { Int($0) })
        
        kwargs.addArgument("--window-title-text", \.titleText,
                           category: .window,
                           help: "Window title text, string, default is 'Yandex.Popup'",
                           parser: { String($0) })
        
        kwargs.addArgument("--window-controls", \.windowControls,
                           category: .window,
                           help: "Window controls bitmask, int [0 - none, 1 - close, 2 - minimize, 4 - fullscreen, 8 - menu], default - 15",
                           parser:  { Int($0) } )
        
        kwargs.addArgument("--window-position", \.position,
                           category: .window,
                           help: "Window semantic position, string [center, left-top, left-bottom, right-top, right-bottom], default - center",
                           parser: { String($0) } )
        
        kwargs.addArgument("--window-position-x", \.position_x,
                           category: .window,
                           help: "Window x position of left-bottom corner, int",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-position-y", \.position_y,
                           category: .window,
                           help: "Window y position of left-bottom corner, int",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-width", \.width,
                           category: .window,
                           help: "Window width, int",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-height", \.height,
                           category: .window,
                           help: "Window height, int",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-floating", \.floating,
                           category: .window,
                           help: "Enables always-on-top floating window, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-hide-dock", \.hideDock,
                           category: .window,
                           help: "Disables Window dock and app switcher visibility, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--window-focus-element", \.windowFocusElement,
                           category: .window,
                           help: "Sets Window input element focus, string [none, okbutton, actionbutton, input], default - none",
                           parser: { String($0) } )
        
        
        // type
        
        kwargs.addArgument("--popup-type", \.type,
                           category: .popupUniversal,
                           help: "Popup type, string [message, input, progress, qrcode, file, dropdown, notification], default is message",
                           parser: { String($0) } )
        
        
        // generic content
        
        kwargs.addArgument("--icon-name", \.iconName,
                           category: .popupUniversal,
                           help: "Generic icon NSImage name, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--icon-path", \.iconPath,
                           category: .popupUniversal,
                           help: "Generic icon path, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--icon-max-width", \.iconMaxWidth,
                           category: .popupUniversal,
                           help: "Generic icon maximum width, int",
                           parser: { Int($0) } )
        
        
        kwargs.addArgument("--header-text", \.headerText,
                           category: .popupUniversal,
                           help: "Generic header text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--description-text", \.descText,
                           category: .popupUniversal,
                           help: "Generic description text, string",
                           parser: { NSMutableAttributedString(string: $0) } )
        
        kwargs.addArgument("--description-detect-links", \.descLinksDetect,
                           category: .popupUniversal,
                           help: "Enables generic description links detection, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--description-links-layout", \.descLinks,
                           category: .popupUniversal,
                           help: "Generic description links layout, string, format='start#end#link|...'",
                           parser: { String($0) } )
        
        kwargs.addArgument("--ok-button", \.okButtonEnabled,
                           category: .popupUniversal,
                           help: "Generic OK button visibility, int [0/1], default = 1",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--ok-button-text", \.okButtonText,
                           category: .popupUniversal,
                           help: "Generic OK button text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--action-button", \.actionButton,
                           category: .popupUniversal,
                           help: "Generic Action Button visibility, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--action-button-actions", \.actionButtonActions,
                           category: .popupUniversal,
                           help: "Generic Action button actions set, string, format='launch#app name|open#file path|open_url#url|exit|exit_err'",
                           parser: { String($0) } )
        
        kwargs.addArgument("--action-button-text", \.actionButtonText,
                           category: .popupUniversal,
                           help: "Generic Action button text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--exit-on-oauth-callback", \.exitOnOauthCallback,
                           category: .popupUniversal,
                           help: "Define app behavior after receiving oauth callback (1 - print to stdout and exit immediately, 0 - print and exit only after user interaction), int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--process-oauth-callback", \.processOauthCallback,
                           category: .popupUniversal,
                           help: "Enable OAuth callback processing, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        // notification
        
        kwargs.addArgument("--notification-type", \.notificationType,
                           category: .notification,
                           help: "Notification type, string [alert, action]",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-title-text", \.notificationTitle,
                           category: .notification,
                           help: "Notification title, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-subtitle-text", \.notificationSubtitle,
                           category: .notification,
                           help: "Notification subtitle, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-body-text", \.notificationBody,
                           category: .notification,
                           help: "Notification title, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-button", \.notificationButton,
                           category: .notification,
                           help: "Show notification button, int [0/1]",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--notification-button-text", \.notificationButtonText,
                           category: .notification,
                           help: "Notification button text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-action", \.notificationActionType,
                           category: .notification,
                           help: "Notification action type, string [launch, open, open_url]",
                           parser: { String($0) } )
        
        kwargs.addArgument("--notification-action-target", \.notificationActionTarget,
                           category: .notification,
                           help: "Notification action target, string",
                           parser: { String($0) } )
        kwargs.addArgument("--notification-critical", \.notificationCritical,
                           category: .notification,
                           help: "Ignore Focus/DnD mode, int [0/1]",
                           parser: { Int($0) } )
        kwargs.addArgument("--notification-thread-id", \.notificationThreadId,
                           category: .notification,
                           help: "Group notifications by threadId, string (default: random)",
                           parser: { String($0) })
        kwargs.addArgument("--notification-fallback-mode", \.notificationFallbackMode,
                           category: .notification,
                           help: "Notification fallback mode if permission not granted, string [disabled, allowed, forced], default = disabled",
                           parser: { String($0) } )
        kwargs.addArgument("--notification-error-on-permission", \.notificationErrorOnPermission,
                           category: .notification,
                           help: "Notification permission error exit code pass mode [0/1], default = 1",
                           parser: { Int($0) } )
        kwargs.addArgument("--notification-fallback-position-origin", \.notificationFallbackPositionOrigin,
                           category: .notification,
                           help: "Notification fallback position origin point, string [top-left, top-right, bottom-right, bottom-left], default = top-right",
                           parser: { String($0) } )
        kwargs.addArgument("--notification-fallback-padding-x", \.notificationFallbackPaddingX,
                           category: .notification,
                           help: "Notification fallback X-axis padding int, default = 20",
                           parser: { Int($0) } )
        kwargs.addArgument("--notification-fallback-padding-y", \.notificationFallbackPaddingY,
                           category: .notification,
                           help: "Notification fallback Y-axis padding int, default = 20",
                           parser: { Int($0) } )
        
        
        // input
        
        kwargs.addArgument("--input-text", \.inputText,
                           category: .input,
                           help: "Input view initial text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--input-placeholder", \.inputPlaceholder,
                           category: .input,
                           help: "Input view placeholder text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--input-secure", \.inputSecure,
                           category: .input,
                           help: "Input view secure input, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--input-secure-set-to-oauth", \.inputSecureSetToOauth,
                           category: .input,
                           help: "If set to 1 will put received OAuth token into secure input field, otherwise will add \"access_token\" to output dictionaary, int [0/1], default = 0",
                           parser: { Int($0) } )
        
        // file input
        
        kwargs.addArgument("--file-mode", \.fileMode,
                           category: .fileInput,
                           help: "FileInput view mode, String [report_path, copy, move], default is report_path",
                           parser: { String($0) } )
        
        kwargs.addArgument("--file-extension", \.fileExtension,
                           category: .fileInput,
                           help: "FileInput view file extension filter, String",
                           parser: { String($0) } )
        
        kwargs.addArgument("--file-destination", \.fileDestination,
                           category: .fileInput,
                           help: "FileInput view file destination path, String",
                           parser: { String($0) } )
        
        kwargs.addArgument("--file-replace", \.fileReplace,
                           category: .fileInput,
                           help: "FileInput view replace destination file, Int [0/1], default = 0",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--file-type", \.fileType,
                           category: .fileInput,
                           help: "FileInput view browse mode, String [file, directory], default = file",
                           parser: { String($0) } )
        
        
        // progress
        
        kwargs.addArgument("--progress-type", \.progressType,
                           category: .progress,
                           help: "Progress view type, String [bar, spinner, completed], default = bar",
                           parser: { String($0) } )
        
        // qrcode
        
        kwargs.addArgument("--qrcode-string", \.qrCodeString,
                           category: .qrcode,
                           help: "Qrcode view string, String",
                           parser: { String($0) } )
        
        kwargs.addArgument("--qrcode-label", \.qrCodeLabel,
                           category: .qrcode,
                           help: "Qrcode label status, int [0/1], default = 1",
                           parser: { Int($0) } )
        
        kwargs.addArgument("--qrcode-label-text", \.qrCodeLabelText,
                           category: .qrcode,
                           help: "Qrcode label text, string",
                           parser: { String($0) } )
        
        kwargs.addArgument("--qrcode-label-text-size", \.qrCodeLabelTextSize,
                           category: .qrcode,
                           help: "Qrcode label text size, int [1-inf], default = 20",
                           parser: { Int($0) } )
        
        // dropdown
        
        kwargs.addArgument("--dropdown-items", \.dropdownItems,
                           category: .dropdown,
                           help: "Comma-separated drop-down menu items, string, e.g.: --dropdown-items='item1, item2, item3'",
                           parser: { String($0) } )
        kwargs.addArgument("--dropdown-default", \.dropdownDefault,
                           category: .dropdown,
                           help: "Drop-down menu item chosen by default, string, if not specified will use the first item from the list") { String($0) }
        
        var res: PopupSettings!
        
        if dictConf == nil {
            res = kwargs.parse()
        }else{
            var conf_args:[String] = []
            
            for key in dictConf!.keys {
                
                if let strValue = dictConf![key] as? String {
                    conf_args.append("--\(key)=\(strValue)")
                }
                
                if let intValue = dictConf![key] as? Int {
                    conf_args.append("--\(key)=\(intValue)")
                }
            }
            
            res = kwargs.parse(args: conf_args)
        }
        
        // system
        
        if res.pidFile == nil { res.pidFile = "" }
        
        // window controls
        if res.windowControls == nil { res.windowControls = 15 }
        
        if res.windowAllSpaces == nil { res.windowAllSpaces = 0 }
        
        // window reset
        
        if res.resetWindow == nil { res.resetWindow = 0 }
        
        // window position
        
        if res.position == nil { res.position = "center" }
        
        // window focus element
        if !(["none", "input", "okbutton", "actionbutton"].contains(res.windowFocusElement)) {
            res.windowFocusElement = "none"
        }

        
        // title
        if res.titleEnabled == nil { res.titleEnabled = 1 }
        if res.titleText == nil { res.titleText = NSRunningApplication.current.localizedName }
        
        // floating
        
        if (res.floating == nil) { res.floating = 0 }
        
        // dock
        
        if (res.hideDock == nil) { res.hideDock = 0 }
        
        // type
        
        if !(["message","input","wifi","progress", "qrcode","file","dropdown","notification"].contains(res.type)) {
            res.type = "message"
        }
        
        // generic content
        
        if res.iconMaxWidth == nil { res.iconMaxWidth = 0 }
        
        if res.headerText == nil { res.headerText = "" }
        if res.descText == nil { res.descText = NSMutableAttributedString(string: "") }
        if res.okButtonText == nil { res.okButtonText = "OK" }
        
        if res.processOauthCallback == nil { res.processOauthCallback = 0 }
        if res.exitOnOauthCallback == nil { res.exitOnOauthCallback = 0 }
        
        // description attributed string
        
        if res.descLinksDetect == 1 {
            
            let linkDetector  = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = linkDetector.matches(in: res.descText!.string, options: [], range: NSRange(location: 0, length: res.descText!.string.utf16.count))
            
            res.descText!.beginEditing()
            
            for match in matches {
                guard let range = Range(match.range, in: res.descText!.string) else { continue }
                let url = res.descText!.string[range]
                
                res.descText!.addAttribute(.link, value: url, range: match.range)
                res.descText!.addAttribute(.foregroundColor, value: NSColor.blue, range: match.range)
                res.descText!.addAttribute(.underlineStyle, value: 1 , range: match.range)
                
            }
            
            res.descText!.endEditing()
            
        }
        
        if res.descLinks != nil {
            let links = res.descLinks!.components(separatedBy: "|").filter { !$0.isEmpty }
            
            res.descText!.beginEditing()
            
            for link:String in links {
                
                let linkComponents = link.components(separatedBy: "#").filter { !$0.isEmpty }
                
                if linkComponents.count == 3 {
                    let range = NSRange(location: Int(linkComponents[0])! , length: Int(linkComponents[1])!)
                    
                    res.descText!.addAttribute(.link, value: linkComponents[2], range: range)
                    res.descText!.addAttribute(.foregroundColor, value: NSColor.blue, range: range)
                    res.descText!.addAttribute(.underlineStyle, value: 1 , range: range)
                }
            }
            
            res.descText!.endEditing()
        }
        
        // action button
        
        if res.actionButton == nil { res.actionButton = 0 }
        if res.actionButtonText == nil { res.actionButtonText = "Action" }
        if res.actionButtonActions == nil { res.actionButtonActions = "" }
        
        // input
        
        if res.inputText == nil { res.inputText = "" }
        if res.inputPlaceholder == nil { res.inputPlaceholder = "" }
        if res.inputSecure == nil { res.inputSecure = 0 }
        if res.inputSecureSetToOauth == nil { res.inputSecureSetToOauth = 0 }
        
        // progress
        
        if res.progressType == nil { res.progressType = "bar" }
        
        
        // file
        
        if !(["report_path","copy","move"].contains(res.fileMode)) {
            res.fileMode = "report_path"
        }
        
        if res.fileReplace == nil { res.fileReplace = 0 }
        if res.fileType == nil { res.fileType = "file" }
        
        if (res.fileMode != "report_path" && res.fileDestination == nil) {
            let stderr = FileHandle.standardOutput
            stderr.write("when using [copy,move] --file-mode you should also specify --file-destination parameter".data(using: .utf8)!)
            exit(1)
        }
        
        
        // qrcode
        
        if res.qrCodeString == nil { res.qrCodeString = NSRunningApplication.current.localizedName }
        if res.qrCodeLabel == nil { res.qrCodeLabel = 1 }
        if res.qrCodeLabelText == nil { res.qrCodeLabelText = res.qrCodeString }
        if res.qrCodeLabelTextSize == nil { res.qrCodeLabelTextSize = 20 }
        
        //dropdown
        
        if res.dropdownItems == nil { res.dropdownItems = "" }
        if res.dropdownDefault == nil { res.dropdownDefault = res.dropdownItems?.components(separatedBy: ", ").first ?? "" }
        
        // notification
        
        if !(["alert","action"].contains(res.notificationType)) {
            res.notificationType = "alert"
        }
        
        if res.notificationTitle == nil { res.notificationTitle = "" }
        if res.notificationSubtitle == nil { res.notificationSubtitle = "" }
        if res.notificationBody == nil { res.notificationBody = "" }
        
        if res.notificationButton == nil { res.notificationButton = 0 }
        if res.notificationButtonText == nil { res.notificationButtonText = "Show" }
        
        if !(["launch","open", "open_url"].contains(res.notificationActionType)) {
            res.notificationActionType = nil
        }
        if res.notificationThreadId == nil { res.notificationThreadId = "random" }
        if res.notificationCritical == nil { res.notificationCritical = 0 }
        
        if res.notificationActionTarget == nil { res.notificationActionTarget = "" }
        if res.notificationFallbackMode == nil { res.notificationFallbackMode = "disabled" }
        if res.notificationErrorOnPermission == nil { res.notificationErrorOnPermission = 1 }
        if res.notificationFallbackPositionOrigin == nil { res.notificationFallbackPositionOrigin = "top-right" }
        if res.notificationFallbackPaddingX == nil { res.notificationFallbackPaddingX = 20 }
        if res.notificationFallbackPaddingY == nil { res.notificationFallbackPaddingY = 20 }
        
        return res
        
    }
    
}
