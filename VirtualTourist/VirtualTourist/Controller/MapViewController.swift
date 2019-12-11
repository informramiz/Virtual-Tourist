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
        updateMapCenter()
    }
    
    private func addMapGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMarker(gesture:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func updateMapCenter() {
        guard UserDefaults.standard.hasData() else { return }
        
        let center = CLLocationCoordinate2D(latitude: UserDefaults.standard.getLatitude(), longitude: UserDefaults.standard.getLongitude())
        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.getLatitudeDelta(), longitudeDelta: UserDefaults.standard.getLongitudeDelta())
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchedResultsContorller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsContorller.delegate = self
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum" {
            let pin = sender as! Pin
            let albumController = segue.destination as! AlbumViewController
            albumController.pin = pin
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
        mapView.deselectAnnotation(view.annotation, animated: true)
        let pin = getPin(view.annotation!.coordinate)
        performSegue(withIdentifier: "showAlbum", sender: pin!)
    }
    
    private func getPin(_ location: CLLocationCoordinate2D) -> Pin? {
        let pins = fetchedResultsContorller.fetchedObjects ?? []
        for pin in pins {
            if pin.latitude == location.latitude && pin.longitude == location.longitude {
                return pin
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let span = mapView.region.span
        UserDefaults.standard.setLatitude(latitude: center.latitude)
        UserDefaults.standard.setLongitude(longitude: center.longitude)
        UserDefaults.standard.setLatitudeDelta(delta: span.latitudeDelta)
        UserDefaults.standard.setLongitudeDelta(delta: span.longitudeDelta)
    }
}

extension MapViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        setupMapMarkers()
    }
}
