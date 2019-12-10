//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Apple on 09/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: MyUICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var pin: Pin!
    private var collectionDataSource: CollectionDataSource<Photo, PhotoCollectionCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
        mapView.isUserInteractionEnabled = false
        print(pin.latitude)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPhotos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionDataSource = nil
    }
    
    private func loadPhotos() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        collectionDataSource = CollectionDataSource(collectionView: collectionView, viewContext: DataController.shared.viewContext, fetchRequest: fetchRequest, configureCell: { (cell, photo) in
            if let imageData = photo.imageData {
                let image = UIImage(data: imageData)
                cell.imageView.image = image
            } else {
                self.downloadImage(photo)
            }
        })
        
        collectionView.dataSource = collectionDataSource
        collectionDataSource.loadData()
        collectionView.reloadData()
        if collectionDataSource.isEmpty {
            fetchPhotosFromNetwork()
        }
    }
    
    private func downloadImage(_ photo: Photo) {
        FlickerAPI.downloadImage(url: photo.imageUrl!) { (data, error) in
            guard let data = data else {return}
            photo.imageData = UIImage(data: data)?.pngData()
            try? DataController.shared.viewContext.save()
        }
    }
    
    private func fetchPhotosFromNetwork() {
        activityIndicator.startAnimating()
        let page = (collectionDataSource.totalItemsCount/FlickerAPI.itemsPerPage) + 1
        FlickerAPI.fetchPhotos(pin: pin, page: page) { (flickerImagesResponse, error) in
            guard let flickerImagesResponse = flickerImagesResponse else {
                print(error!.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            
            self.activityIndicator.stopAnimating()
            for images in flickerImagesResponse.imagesPage.images {
                let photo = Photo(context: DataController.shared.viewContext)
                photo.pin = self.pin
                photo.imageUrl = images.url
                DataController.shared.viewContext.insert(photo)
            }
            try? DataController.shared.viewContext.save()
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        fetchPhotosFromNetwork()
    }
}
