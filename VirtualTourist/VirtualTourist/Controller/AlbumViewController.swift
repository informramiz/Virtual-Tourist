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
    private var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noImagesLabel.isHidden = true
        mapView.isUserInteractionEnabled = false
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
                cell.imageView.image = nil
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
        setLoading(true)
        page += 1
        if page > FlickerAPI.maxPages {
            page = 1
        }
        FlickerAPI.fetchPhotos(pin: pin, page: page) { (flickerImagesResponse, error) in
            guard let flickerImagesResponse = flickerImagesResponse else {
                self.showErrorAlert(message: error!.localizedDescription)
                self.setLoading(false)
                return
            }
            
            self.setLoading(false)
            let filteredImages = flickerImagesResponse.imagesPage.images.filter { (image) -> Bool in
                image.url != nil
            }
            for image in filteredImages {
                let photo = Photo(context: DataController.shared.viewContext)
                photo.pin = self.pin
                photo.imageUrl = image.url!
            }
            try? DataController.shared.viewContext.save()
            self.collectionView.reloadData()
            self.noImagesLabel.isHidden = !filteredImages.isEmpty
            self.newCollectionButton.isEnabled = !filteredImages.isEmpty
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        newCollectionButton.isEnabled = !isLoading
    }
    
    @IBAction func newCollection(_ sender: Any) {
        collectionDataSource.deleteAllItems()
        fetchPhotosFromNetwork()
    }
}
