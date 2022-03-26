//
//  CustomPersistenceContainer.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 22/09/2021.
//

import CoreData

class CustomPersistenceContainer: NSPersistentContainer {
    
    override class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.MHAH.SpendingTrackerSwiftUICoreDataLBTA.DBS")
        storeURL = storeURL?.appendingPathComponent("MHAH.SpendingTrackerSwiftUICoreDataLBTA.DBS.sqlite")
        
        return storeURL!
    }
}
