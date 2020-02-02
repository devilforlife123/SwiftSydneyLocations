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

    var viewModel:SearchViewModel = SearchViewModel.shared
    var refreshBarButton:UIBarButtonItem!
    var selectedLocation:Location? = nil
    @IBOutlet weak var mapView:MKMapView!
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self

        self.configureUIElements()
        self.configureClosures()
        activityIndicatorView.startAnimating()
        viewModel.loadLocations()
        let authStatus = CLLocationManager.authorizationStatus()
         if authStatus == .notDetermined {
           locationManager.requestWhenInUseAuthorization()
         }
                     
         if authStatus == .denied || authStatus == .restricted {
           showAlert(message: "Please enable location services for this app in Settings.")
         }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.mapView.removeAnnotations(self.mapView.annotations)
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

        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "LocationView")
        if annotationView == nil {
            annotationView = LocationAnnotationView(annotation: annotation, reuseIdentifier: "LocationView")
            (annotationView as! LocationAnnotationView).locationDetailDelegate = self
        } else {
            annotationView!.annotation = annotation
        }
        if let isAdded = (annotation as! Location).isAdded{
                  if isAdded{
                    (annotationView as! LocationAnnotationView).image = resizedCustomPinImage
                  }else{
                    (annotationView as! LocationAnnotationView).image = UIImage(named:"Flag")
                  }
              }else{
                  (annotationView as! LocationAnnotationView).image = UIImage(named:"Flag")
        }
        return annotationView
    }
    
       func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        var i = -1;
        for view in views {
            i += 1;
            if view.annotation is MKUserLocation {
                continue;
            }
            let point:MKMapPoint  =  MKMapPoint(view.annotation!.coordinate);
            if (!self.mapView.visibleMapRect.contains(point)) {
                continue;
            }
            let endFrame:CGRect = view.frame;
            view.frame = CGRect(origin: CGPoint(x: view.frame.origin.x,y :view.frame.origin.y-self.view.frame.size.height), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            let delay = 0.03 * Double(i)
            UIView.animate(withDuration: 0.5, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                view.frame = endFrame
            }, completion:{(Bool) in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.6)
                }, completion: {(Bool) in
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                        view.transform = CGAffineTransform.identity
                    }, completion: nil)
                })
            })
        }
    }
    
    
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            self.selectedLocation = view.annotation as? Location
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
           self.showLocations()
               
        }
    }
extension ViewController:LocationDetailDelegate{
    
    func detailsShownForLocation(location: Location) {
               self.selectedLocation = location
               self.performSegue(withIdentifier: "EditDescription", sender: nil)
        }
    
}

extension ViewController:CLLocationManagerDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        viewModel.userLocation = userLocation.coordinate
    }
}

