//
//  AppDelegate.swift
//  PodfileLock
//
//  Created by 聂小波 on 2024/5/16.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("用户点击了应用程序图标 Terminat")
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        // 用户点击应用程序图标时的处理
        // 在这里执行你想要的操作
        print("用户点击了应用程序图标 BecomeActive")
    }
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 返回 true 表示关闭主窗口后直接退出应用程序
        return true
    }
}
