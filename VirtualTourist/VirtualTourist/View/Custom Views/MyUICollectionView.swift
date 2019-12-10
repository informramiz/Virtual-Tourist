//
//  MyUICollectionView.swift
//  VirtualTourist
//
//  Created by Apple on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Add support for NSFetchedResultsControllerDelegate
class MyUICollectionView: UICollectionView {
    //because CollectionView does not have beginUpdates() and endUpdates() method like tableview so
    //we need to implement that functionality ourself. Below are variables to keep track of changes
    private var itemChanges = [NSFetchedResultsChangeType: IndexPath]()
    private var sectionChanges = [NSFetchedResultsChangeType: IndexSet]()
    
    func itemDidChange(indexPath: IndexPath?, type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //keep track of all items related changes in self.itemChanges dictionary so that we can apply them in batch
        switch type {
        case .insert:
            itemChanges[type] = newIndexPath
            break
        case .delete, .update:
            itemChanges[type] = indexPath
            break
        default:
            reloadData()
            break
        }
    }
    
    func sectionDidChange(sectionIndex: Int, type: NSFetchedResultsChangeType) {
        //keep track of section related changes so that we can apply them in batch
        let indexSet = IndexSet(integer: sectionIndex)
        sectionChanges[type] = indexSet
    }
    
    func beginUpdates() {
        //BeginUpdates: new changes are about to begin so discard outdated changes that we have already applied
        itemChanges.removeAll()
        sectionChanges.removeAll()
    }
    
    func endUpdates() {
        //EndUpdates: Now all changes are triggered, let's apply all changes in batch
        performBatchUpdates({
            //apply section related changes
            for (type, indexSet) in sectionChanges {
                applySectionChange(type, indexSet)
            }
            
            //apply items changes
            for (type, indexPath) in itemChanges {
                applyItemChange(type, indexPath)
            }
        }, completion: nil)
    }
    
    private func applyItemChange(_ type: NSFetchedResultsChangeType, _ indexPath: IndexPath) {
        switch type {
        case .insert:
            insertItems(at: [indexPath])
            break
        case .delete:
            deleteItems(at: [indexPath])
            break
        case .update:
            reloadItems(at: [indexPath])
        default:
            reloadData()
            break
        }
    }
    
    private func applySectionChange(_ type: NSFetchedResultsChangeType, _ indexSet: IndexSet) {
        switch type {
        case .insert:
            insertSections(indexSet)
        case .delete:
            deleteSections(indexSet)
        default:
            reloadData()
        }
    }
}
