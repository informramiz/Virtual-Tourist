//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Apple on 09/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import UIKit
import MapKit

class AlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: MyUICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var pin: Pin!
    override func viewDidLoad() {
        super.viewDidLoad()
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
        mapView.isUserInteractionEnabled = false
        print(pin.latitude)
        
        FlickerAPI.fetchPhotos(pin: pin, page: 1) { (flickerImagesResponse, error) in
            print(flickerImagesResponse)
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        
    }
}
