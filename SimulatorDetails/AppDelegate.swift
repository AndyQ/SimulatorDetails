//
//  AppDelegate.swift
//  SimulatorDetails
//
//  Created by Andy Qua on 06/11/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/andyq/SimulatorDetails
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        applicationController = NSApplication.sharedApplication().mainWindow!.windowController()! as? NSWindowController
    }
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(app: NSApplication) -> Bool { return false }
    
    var applicationController: NSWindowController?
    @IBAction func showApplication(sender : AnyObject)
    {
        if applicationController == nil
        {
            if let storyboard = NSStoryboard(name: "Main", bundle: nil)
            {
                applicationController = storyboard.instantiateInitialController() as? NSWindowController
                if let window = applicationController?.window {
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = NSWindowTitleVisibility.Hidden
                    window.styleMask |= NSFullSizeContentViewWindowMask
                }
            }
            
        }
        if applicationController != nil { applicationController!.showWindow(sender) }
    }

}

