//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Ramiz on 09/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        addMapGesture()
    }
    
    private func addMapGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMarker(gesture:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    fileprivate func addMapMarker(_ pinCoordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinates
        mapView.addAnnotation(annotation)
    }
    
    @objc
    private func addMarker(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // gesture accepted
            let pinPoint = gesture.location(in: mapView)
            let pinCoordinates = mapView.convert(pinPoint, toCoordinateFrom: mapView)
            addMapMarker(pinCoordinates)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            annotationView?.animatesDrop = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "showAlbum", sender: nil)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

