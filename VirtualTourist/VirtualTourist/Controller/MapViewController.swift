//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Ramiz on 09/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    private var fetchedResultsContorller: NSFetchedResultsController<Pin>!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchedResultsContorller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsContorller.delegate = self
        
        do {
            try fetchedResultsContorller.performFetch()
            setupMapMarkers()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func setupMapMarkers() {
        mapView.removeAnnotations(mapView.annotations)
        let pins = fetchedResultsContorller.fetchedObjects ?? []
        for pin in pins {
            addMapMarker(pin.toCLLocationCoordinate2D())
        }
    }
    
    private func addMapMarker(_ pinCoordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinates
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsContorller = nil
    }
    
    @objc
    private func addMarker(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // gesture accepted
            let pinPoint = gesture.location(in: mapView)
            let pinCoordinates = mapView.convert(pinPoint, toCoordinateFrom: mapView)
            addMarkerToDb(location: pinCoordinates)
            addMapMarker(pinCoordinates)
        }
    }
    
    private func addMarkerToDb(location: CLLocationCoordinate2D) {
        let pin = Pin(context: DataController.shared.viewContext)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        DataController.shared.viewContext.insert(pin)
        try? DataController.shared.viewContext.save()
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

//extension MapViewController : NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        let a = 0
//        print(a)
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("item changed")
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        print("section changed")
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        setupMapMarkers()
//    }
//}
