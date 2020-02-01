//
//  ViewController.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    var viewModel:SearchViewModel = SearchViewModel()
    var refreshBarButton:UIBarButtonItem!
    var selectedLocation:Location? = nil
    @IBOutlet weak var mapView:MKMapView!
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
          locationManager.requestWhenInUseAuthorization()
          return
        }
        
        if authStatus == .denied || authStatus == .restricted {
          showAlert(message: "Please enable location services for this app in Settings.")
          return
        }
        self.configureUIElements()
         self.configureClosures()
        activityIndicatorView.startAnimating()
        viewModel.loadLocations()
    }
    
    func configureClosures(){
          
      viewModel.showAlert = { [weak self]
                   (message) in
            GCD.runOnMainThread {
                self?.showAlert(message: message)
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                self?.activityIndicatorView.stopAnimating()
            }
                 
       }
        
        viewModel.dataUpdated = {
            [weak self] in
            GCD.runOnMainThread {
                self?.addAnnotations()
                self?.showLocations()
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func configureUIElements(){
           self.refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action:#selector(refreshMapView))
                  refreshBarButton.tintColor = UIColor.black
                  navigationItem.rightBarButtonItem = refreshBarButton
                  navigationItem.rightBarButtonItem?.isEnabled = false
        let region = MKCoordinateRegion(.world)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        activityIndicatorView.center = mapView.center
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
    }
    
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        let location = Location(coordinate: touchMapCoordinate)

        mapView.addAnnotation(location)
        viewModel.locationsArray.append(location)
        try! viewModel.save()
        
        GCD.afterDelay(2) {
            self.selectedLocation = location
            self.performSegue(withIdentifier: "EditDescription", sender: nil)
        }
        
    }
    
    @objc func refreshMapView(){
        activityIndicatorView.startAnimating()
         viewModel.locationsArray = []
         viewModel.loadLocations()
    }
    
    
    func addAnnotations() {
        
            self.mapView.removeAnnotations(self.viewModel.locationsArray)
            self.mapView.addAnnotations(self.viewModel.locationsArray)
    }
    
    func showLocations(){
        let theRegion = region(for: viewModel.locationsArray)
        mapView.setRegion(theRegion, animated: false)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
      let region: MKCoordinateRegion
      
      switch annotations.count {
      case 0:
        region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
      default:
        var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in annotations {
          topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
          topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
          bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
          bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2, longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
        
        let extraSpace = 1.1
        let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
        
        region = MKCoordinateRegion(center: center, span: span)
      }
      return mapView.regionThatFits(region)
    }
    
    private func showAlert(title: String = "Location App", message: String?) {
         let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
         let okAction = UIAlertAction(title:NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) {(action) in
         }
         alertController.addAction(okAction)
         present(alertController, animated: true, completion: nil)
    }
}
extension ViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
          return nil
        }
       let identifier = "LocationView"
        
    
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
          let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

          pinView.isEnabled = true
          pinView.canShowCallout = true
          pinView.animatesDrop = true
          let rightButton = UIButton(type: .detailDisclosure)
          rightButton.addTarget(self, action: #selector(showLocationDescription(_:)), for: .touchUpInside)
          pinView.rightCalloutAccessoryView = rightButton
          annotationView = pinView
        }

        if let annotationView = annotationView {

          annotationView.annotation = annotation
        }
        if let _ = (annotation as! Location).isAdded{
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.brown
        }else{
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.red
        }
        var locationImage:UIImage!
          if let data = (annotation as! Location).imageData{
              locationImage = UIImage(data: data)
          }else{
              locationImage = UIImage(named:"Flag")
          }
        let locationImageView =  UIImageView(frame: CGRect(x: 0, y: 0, width: annotationView!.frame.height, height: annotationView!.frame.height))
        locationImageView.image = locationImage
        annotationView?.leftCalloutAccessoryView = locationImageView
        let detailLabel = UILabel()
             detailLabel.numberOfLines = 0
             detailLabel.font = detailLabel.font.withSize(15)
            detailLabel.text = (annotation as! Location).locationDescription ?? ("No Description")
        annotationView?.detailCalloutAccessoryView = detailLabel
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            selectedLocation = view.annotation as? Location
        }
        
        @objc func showLocationDescription(_ sender: UIButton) {
            
           performSegue(withIdentifier: "EditDescription", sender: sender)
         }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "EditDescription"{
                let controller = segue.destination as! EditDescriptionViewController
                controller.delegate = self
                controller.location = selectedLocation
            }
        }
    
    @IBAction func showUserCurrentLocation() {
       let theRegion = region(for: [])
       mapView.setRegion(theRegion, animated: true)
     }

    }

    extension ViewController:LocationDelegate{
        
        func locationDeleted(_ deletedLocation:Location){
            viewModel.locationsArray.removeAll { (location) -> Bool in
                return location == deletedLocation
            }
            self.mapView.removeAnnotation(deletedLocation)
            try! DiskCareTaker.save(viewModel.locationsArray, to: viewModel.fileName)
            addAnnotations()
            self.showLocations()
        }
        
       func locationDetailsChanged(_ changedLocation: Location) {
               
           let location = viewModel.locationsArray.filter({$0 == changedLocation}).first
           location?.locationDescription = changedLocation.locationDescription
           location?.name = changedLocation.name
           location?.imageData = changedLocation.imageData
           try! DiskCareTaker.save(viewModel.locationsArray, to: viewModel.fileName)
           addAnnotations()
           self.showLocations()
               
        }
    }

