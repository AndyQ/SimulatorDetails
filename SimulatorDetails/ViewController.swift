//
//  ViewController.swift
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

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate
{
    @IBOutlet weak var simulatorTableView: NSTableView!
    @IBOutlet weak var appTableView: NSTableView!
    @IBOutlet weak var iosVersionComboBox: NSComboBox!
    @IBOutlet weak var lblAppBinaryLocation: NSTextField!
    @IBOutlet weak var lblAppDocumentsLocation: NSTextField!
    
    
    let simDataManager = SimDataManager();
    var iosVersions = [String]()
    var appList = [String]()
    
    var selectedIOSVersion : String?
    var selectedIOSSimulator : Simulator?


    override func viewDidLoad() {
        super.viewDidLoad()

        simDataManager.getListOfSimulators()
        iosVersions = simDataManager.simulators.keys.array.sorted(<)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        selectedIOSVersion = defaults.stringForKey("iosVersion")
        let selectedIOSSimulatorName = defaults.stringForKey("deviceName")
        if selectedIOSSimulatorName != nil && selectedIOSVersion != nil
        {
            // Set combobox text
            iosVersionComboBox.objectValue = selectedIOSVersion
            var index = simDataManager.getIndexOfSimulator(selectedIOSVersion!, deviceName: selectedIOSSimulatorName!)
            if index != -1
            {
                delay( 0.2 ) { self.simulatorTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false) }
            }
        }

        self.lblAppBinaryLocation.stringValue = ""
        self.lblAppDocumentsLocation.stringValue = ""
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func refreshAppListPressed(sender: AnyObject)
    {
        appTableView.deselectRow(appTableView.selectedRow)
        appList = selectedIOSSimulator!.getListOfApps()
        self.lblAppBinaryLocation.stringValue = ""
        self.lblAppDocumentsLocation.stringValue = ""

        self.appTableView.reloadData()
    }
    
    @IBAction func openAppBinaryFolderPressed(sender: AnyObject)
    {
        NSWorkspace.sharedWorkspace().openFile(lblAppBinaryLocation.stringValue )
    }
    
    @IBAction func openAppDocsFolderPressed(sender: AnyObject)
    {
        NSWorkspace.sharedWorkspace().openFile(lblAppDocumentsLocation.stringValue )
    }
    
    // MARK: mark Table view methods
    func numberOfRowsInTableView( tableView : NSTableView ) -> Int
    {
        if selectedIOSVersion == nil
        {
            return 0
        }
        
        if ( tableView == simulatorTableView )
        {
            return simDataManager.simulators[selectedIOSVersion!]!.count
        }
        else
        {
            return appList.count
        }
    }
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        var newString : String?
        if ( tableView == simulatorTableView )
        {
            
            newString = simDataManager.simulators[selectedIOSVersion!]![row].deviceName
        }
        else
        {
            newString = appList[row]
            newString = "MyApp \(row)"
        }
        return newString;
    }

    func tableViewSelectionDidChange(notification: NSNotification)
    {
        let tableView = notification.object as NSTableView
        if ( tableView == simulatorTableView && tableView.selectedRow != -1 )
        {
            selectedIOSSimulator = simDataManager.simulators[selectedIOSVersion!]![tableView.selectedRow] as Simulator
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(selectedIOSSimulator!.deviceName, forKey: "deviceName")
            defaults.synchronize()
            
            appTableView.deselectRow(appTableView.selectedRow)
            appList = selectedIOSSimulator!.getListOfApps()
            self.lblAppBinaryLocation.stringValue = ""
            self.lblAppDocumentsLocation.stringValue = ""

            self.appTableView.reloadData()
        }
        else if ( tableView == appTableView && tableView.selectedRow != -1 )
        {
            var sim = simDataManager.simulators[selectedIOSVersion!]![self.simulatorTableView.selectedRow] as Simulator
            var appName = appList[appTableView.selectedRow]
            
            if let appDetails = sim.getAppDetails(appName)
            {
                self.lblAppBinaryLocation.stringValue = appDetails.appFolder
                self.lblAppDocumentsLocation.stringValue = appDetails.dataFolder
            }
        }
    }
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int
    {
        return iosVersions.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return iosVersions[index]
    }
    
    func comboBoxSelectionDidChange(notification: NSNotification)
    {
        selectedIOSVersion = iosVersions[self.iosVersionComboBox.indexOfSelectedItem]

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(selectedIOSVersion!, forKey: "iosVersion")
        defaults.synchronize()

        self.simulatorTableView.reloadData()

    }
}
