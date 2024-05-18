//
//  Ext.swift
//  PodfileLock
//
//  Created by 聂小波 on 2024/5/17.
//

import Cocoa
import Foundation


extension NSAlert {
    func show(title: String, msg: String) {
        let alert = self
        alert.addButton(withTitle: "Ok")
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .warning
        alert.runModal()
    }
}



extension String {
    func color() -> NSColor {
        NSColor(hexString: self) ?? .black
    }
    static func colors() -> [String] {
        [
            "#B71C1C", "#0D47A1", "#BDBDBD", "#607D8B", "#5D6D7E",
            "#424242", "#2E7D32", "#8D6E63", "#4A148C", "#C62828",
            "#FF5722", "#795548", "#9C27B0", "#FFC107", "#009688"
        ]
    }
}

extension NSColor {
    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
