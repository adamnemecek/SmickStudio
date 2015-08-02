//
//  AppDelegate.swift
//  SmickStudio
//
//  Created by Omar Qazi on 8/1/15.
//  Copyright (c) 2015 Omar Qazi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public var liveWindow: NSWindowController?
    public var broadcastWindow: NSWindowController?


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            self.liveWindow?.showWindow(self)
            return true
        } else {
            return false
        }
    }


}

