//
//  DataController.swift
//  VirtualTourist
//
//  Created by Apple on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    private let persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    private var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    static var shared = DataController(modelName: "RR-VirtualTourist")
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
