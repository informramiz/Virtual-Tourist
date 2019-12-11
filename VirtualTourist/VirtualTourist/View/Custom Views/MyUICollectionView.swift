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
    private let changeKeeper: ChangeKeeper = ChangeKeeper()
    
    struct ItemChangeKeeper {
        var insertedItems = [IndexPath]()
        var deletedItems = [IndexPath]()
        var updatedItems = [IndexPath]()
        var movedItems = [IndexPath]()
    }
    
    struct SectionChangeKeeper {
        var insertedSections = [IndexSet]()
        var deletedSections = [IndexSet]()
    }
    
    class ChangeKeeper {
        var itemChangeKeeper = [NSFetchedResultsChangeType: [IndexPath]]()
        var sectionChangeKeeper = [NSFetchedResultsChangeType: [IndexSet]]()
        
        func addSectionChange(type: NSFetchedResultsChangeType, sectionIndex: Int) {
            var array = sectionChangeKeeper[type] ?? []
            array.append(IndexSet(integer: sectionIndex))
            sectionChangeKeeper[type] = array
            
            clearItemsFor(section: sectionIndex, sectionType: type)
        }
        
        func addItemChange(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
            var changes = itemChangeKeeper[type] ?? []
            switch type {
            case .insert:
                changes.append(newIndexPath!)
                break
            case .delete, .update:
                changes.append(indexPath!)
                break
            default:
                break
            }
            itemChangeKeeper[type] = changes
        }
        
        private func clearItemsFor(section: Int, sectionType: NSFetchedResultsChangeType) {
            switch sectionType {
            case .insert:
                clearItemsFor(section: section, itemChangeType: .insert)
            case .delete:
                clearItemsFor(section: section, itemChangeType: .delete)
                clearItemsFor(section: section, itemChangeType: .update)
            default:
                break
            }
        }
        
        private func clearItemsFor(section: Int, itemChangeType: NSFetchedResultsChangeType) {
            let items = itemChangeKeeper[itemChangeType] ?? []
            itemChangeKeeper[itemChangeType] = items.filter { (indexPath) -> Bool in
                return indexPath.section != section
            }
        }
        
        func clearChanges() {
            itemChangeKeeper.removeAll()
            sectionChangeKeeper.removeAll()
        }
    }
    
    func itemDidChange(indexPath: IndexPath?, type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //keep track of all items related changes in self.itemChanges dictionary so that we can apply them in batch
        changeKeeper.addItemChange(type: type, indexPath: indexPath, newIndexPath: newIndexPath)
    }
    
    func sectionDidChange(sectionIndex: Int, type: NSFetchedResultsChangeType) {
        //keep track of section related changes so that we can apply them in batch
        changeKeeper.addSectionChange(type: type, sectionIndex: sectionIndex)
    }
    
    func beginUpdates() {
        //BeginUpdates: new changes are about to begin so discard outdated changes that we have already applied
        changeKeeper.clearChanges()
    }
    
    func endUpdates() {
        //EndUpdates: Now all changes are triggered, let's apply all changes in batch
        performBatchUpdates({
            //apply section related changes
            for (type, indexSets) in changeKeeper.sectionChangeKeeper {
                for indexSet in indexSets {
                    applySectionChange(type, indexSet)
                }
            }
            
            
            
            //apply items changes
            for (type, indexPaths) in changeKeeper.itemChangeKeeper {
                for indexPath in indexPaths {
                    applyItemChange(type, indexPath)
                }
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
