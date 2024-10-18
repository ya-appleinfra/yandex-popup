//
//  FileInputViewController.swift
//  Yandex.Popup
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class FileInputViewController: PopupViewController, NSOpenSavePanelDelegate {
    
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        if popupSettings?.fileExtension == nil { return true }
        if url.isDirectory && url.pathExtension == "" { return true }
        if url.pathExtension == popupSettings?.fileExtension { return true }
        return false
    }
    
    @IBAction func browsePushed(sender: Any) {
    
        
        let panel = NSOpenPanel()
        
        panel.delegate = self

        if popupSettings?.fileType == "file" {
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
        }else{
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
        }
        
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            inputField?.stringValue = panel.url!.path
        }
        
    }
    
    @IBAction override func okPushed(sender: Any) {
        
        let stdout = FileHandle.standardOutput
        let stderr = FileHandle.standardError

        let file_path = inputField?.stringValue

        if file_path!.count == 0 {
            stderr.write("No file choosed".data(using: .utf8)!)
            exit(1)
        }

        if !FileManager.default.fileExists(atPath: file_path!) {
            stderr.write("Choosen file do not exists".data(using: .utf8)!)
            exit(1)
        }
        
        switch(popupSettings?.fileMode) {
        case "copy","move":
            if FileManager.default.fileExists(atPath: popupSettings!.fileDestination!) {
                
                if popupSettings?.fileReplace == 0 {
                    stderr.write("destination file already exists".data(using: .utf8)!)
                    exit(1)
                }else{
                
                    do {
                        try FileManager.default.removeItem(atPath: popupSettings!.fileDestination!)
                        
                    } catch {
                        stderr.write("error removing destination file: \(error)".data(using: .utf8)!)
                        exit(1)
                    }
                }
            }
        
            do {
                if popupSettings?.fileMode == "copy" {
                    try FileManager.default.copyItem(atPath: file_path!, toPath: popupSettings!.fileDestination!)
                }
                
                if popupSettings?.fileMode == "move" {
                    try FileManager.default.moveItem(atPath: file_path!, toPath: popupSettings!.fileDestination!)
                }
                
            }catch{
                stderr.write("error copying file to destination: \(error)".data(using: .utf8)!)
                exit(1)
            }

        case "report_path":
            stdout.write(file_path!.data(using: .utf8)!)
            NSApp.terminate(self)
        case .none:
            stdout.write(file_path!.data(using: .utf8)!)
            NSApp.terminate(self)
        case .some(_):
            stdout.write(file_path!.data(using: .utf8)!)
            NSApp.terminate(self)
        }
        
        super.okPushed(sender: sender)
    }
    
}
