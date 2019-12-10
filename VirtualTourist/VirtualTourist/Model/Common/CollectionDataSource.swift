//
//  CollectionDataSource.swift
//  VirtualTourist
//
//  Created by Apple on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CollectionDataSource<EntityType: NSManagedObject, CellType: UICollectionViewCell>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    private let collectionView: MyUICollectionView
    private let viewContext: NSManagedObjectContext
    private let configureCell: (CellType, EntityType) -> Void
    private let fetchedResultsController: NSFetchedResultsController<EntityType>
    private let cellIdentifier = String(describing: CellType.self)
    var onContentUpdated: (() -> Void)? = nil
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    var isEditingPossible: Bool {
        return numberOfRowsIn(section: 0) > 0
    }
    
    init(collectionView: MyUICollectionView, viewContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<EntityType>,
         configureCell: @escaping (CellType, EntityType) -> Void) {
        self.collectionView = collectionView
        self.viewContext = viewContext
        self.configureCell = configureCell
        fetchedResultsController = NSFetchedResultsController<EntityType>(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        loadData()
    }
    
    private func loadData() {
        collectionView.dataSource = self
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            collectionView.reloadData()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CollectionView Data Source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRowsIn(section: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CellType
        let model = fetchedResultsController.object(at: indexPath)
        configureCell(cell, model)
        return cell
    }
    
    
    
    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       switch editingStyle {
       case .delete: deleteItem(at: indexPath)
       default: () // Unsupported
       }
   }
    
    /// Deletes the item at the specified index path
    func deleteItem(at indexPath: IndexPath) {
        //delete from core data first
        let itemToDelete = object(at: indexPath)
        viewContext.delete(itemToDelete)
        try? viewContext.save()
    }
    
    // MARK: - NSFetchedResultsController delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.endUpdates()
        onContentUpdated?()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.itemDidChange(indexPath: indexPath, type: type, newIndexPath: newIndexPath)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        collectionView.sectionDidChange(sectionIndex: sectionIndex, type: type)
    }
    
    // MARK: Utility methods
    func numberOfRowsIn(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> EntityType {
        return fetchedResultsController.object(at: indexPath)
    }
}
