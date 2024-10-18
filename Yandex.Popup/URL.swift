//
//  URL.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
