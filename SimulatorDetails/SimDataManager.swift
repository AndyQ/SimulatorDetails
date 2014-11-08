//
//  SimDataManager.swift
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

import Foundation;

let simDevicesFolder = "~/Library/Developer/CoreSimulator/Devices".stringByExpandingTildeInPath
let simRuntimePrefix = "com.apple.CoreSimulator.SimRuntime."
let simDeviceTypePrefix = "com.apple.CoreSimulator.SimDeviceType."
let appMetadataFile = ".com.apple.mobile_container_manager.metadata.plist"
let containerFolder = "data/Containers"
let appsFolder = containerFolder.stringByAppendingPathComponent( "Bundle/Application" )
let dataFolder = containerFolder.stringByAppendingPathComponent( "Data/Application" )


class AppDetails : Printable
{
    var appName : String = ""
    var appFolder : String = ""
    var appBundleId : String = ""
    var dataFolder : String = ""
    
    var description: String {
        return "appName: \(appName)\n    appFolder: \(appFolder)\n    dataFolder: \(dataFolder)"
    }
}

class Simulator : Printable
{
    var folder : String = ""
    var deviceName : String = ""
    var deviceType : String = ""
    var iosVersion : String = ""
    var UDID : String = ""
    var state : Int = 0
    
    var description: String {
        return "deviceName: \(deviceName), deviceType: \(deviceType), iosVersion: \(iosVersion), state: \(state)"
    }
    
    func getListOfApps( ) -> [String]
    {
        var simAppsDir = self.folder.stringByAppendingPathComponent(appsFolder)

        let fm = NSFileManager.defaultManager();
        var apps = [String]()
        if let appDirs = fm.contentsOfDirectoryAtPath( simAppsDir, error: nil ) as? [String]
        {
            for appDir in appDirs
            {
                var appFolder = simAppsDir.stringByAppendingPathComponent(appDir)
                if let files = fm.contentsOfDirectoryAtPath( appFolder, error: nil ) as? [String]
                {
                    for file in files
                    {
                        if ( file.hasSuffix(".app" ) )
                        {
                            let appName = file.stringByDeletingPathExtension
                            apps.append(appName)
                        }
                    }
                }
            }
        }
        
        apps.sort(<)
        return apps;
    }
    
    
    func getAppDetails( appName : String ) -> AppDetails?
    {
        // Get details of app
        var appSearchingFor = appName.stringByAppendingPathExtension("app")
        var simAppsDir = self.folder.stringByAppendingPathComponent(appsFolder)
        
        let fm = NSFileManager.defaultManager();
        var appDirs = fm.contentsOfDirectoryAtPath( simAppsDir, error: nil )
        var retApp : AppDetails?
        for appDir in appDirs! as [String]
        {
            var appFolder = simAppsDir.stringByAppendingPathComponent(appDir)
            var files = fm.contentsOfDirectoryAtPath( appFolder, error: nil )
            
            var dataFolder = ""
            for file in files! as [String]
            {
                if file == appSearchingFor
                {
                    retApp = AppDetails()
                    retApp!.appName = appName
                    retApp!.appFolder = appFolder
                    break;
                }
            }
            
            if retApp != nil
            {
                break;
            }
        }
        
        
        if let app = retApp
        {
            var appDir = app.appFolder
            var dataDir = self.folder.stringByAppendingPathComponent(dataFolder)

            
            // First get the app bundle id
            let plistFile = appDir.stringByAppendingPathComponent( appMetadataFile )
            if let d = NSDictionary(contentsOfFile: plistFile )
            {
                var dict = d as [String:AnyObject]
                if let val = dict["MCMMetadataIdentifier"] as? String
                {
                    app.appBundleId = val
                }
            }
            
            // Now go through the data folder and find th data folder that has the same bundle id
            
            let fm = NSFileManager.defaultManager();
            var dataDirs = fm.contentsOfDirectoryAtPath( dataDir, error: nil )
            for dir in dataDirs as [String]!
            {
                let f = dataDir.stringByAppendingPathComponent(dir)
                let plistFile = f.stringByAppendingPathComponent( appMetadataFile )
                if let d = NSDictionary(contentsOfFile: plistFile )
                {
                    var dict = d as [String:AnyObject]
                    if let val = dict["MCMMetadataIdentifier"] as? String
                    {
                        if ( val == app.appBundleId )
                        {
                            app.dataFolder = f
                            break
                        }
                    }
                }
            }
        }
        
        return retApp
    }
}
    

class SimDataManager
{
    var simulators = [String: [Simulator]]()
    
    init()
    {
        getListOfSimulators()
    }
    
    func getListOfSimulators()
    {
        simulators.removeAll(keepCapacity: false )
        
        let fm = NSFileManager.defaultManager();
        var dirs = fm.contentsOfDirectoryAtPath( simDevicesFolder, error: nil )
        for dir in dirs! as [String]
        {
            let plistFile = simDevicesFolder.stringByAppendingPathComponent( dir ).stringByAppendingPathComponent("device.plist" )
            if let d = NSDictionary(contentsOfFile: plistFile )
            {
                var dict = d as [String:AnyObject]
                
                let sim = Simulator()
                sim.folder = simDevicesFolder.stringByAppendingPathComponent( dir )
                sim.deviceName = dict["name"]! as String
                sim.deviceType = (dict["deviceType"]! as NSString).stringByReplacingOccurrencesOfString(simDeviceTypePrefix, withString: "" )
                sim.iosVersion = (dict["runtime"]! as NSString).stringByReplacingOccurrencesOfString(simRuntimePrefix, withString: "" )
                sim.UDID = dict["UDID"]! as String
                sim.state = dict["state"]! as Int
                println( "\(sim)" )
                
                if simulators[sim.iosVersion] != nil
                {
                    simulators[sim.iosVersion]!.append( sim )
                }
                else
                {
                    simulators[sim.iosVersion] = [sim]
                }
            }
        }
    }

    func getIndexOfSimulator( iosVersion : String, deviceName: String ) -> Int
    {
        var retIndex : Int = -1
        if let versionDict = simulators[iosVersion]
        {
            var index = 0
            for sim in versionDict
            {
                if sim.deviceName == deviceName
                {
                    retIndex = index;
                    break;
                }
                index++
            }
        }
        return retIndex;

    }

    func getSimulator( iosVersion : String, deviceName: String ) -> Simulator?
    {
        var retSim : Simulator?
        var index = getIndexOfSimulator(iosVersion, deviceName: deviceName)
        if ( index != -1 )
        {
            retSim = simulators[iosVersion]![index]
        }
        
        return retSim;
    }
}
