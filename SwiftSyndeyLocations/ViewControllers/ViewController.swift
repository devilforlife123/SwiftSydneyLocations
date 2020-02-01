//
//  ViewController.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    var viewModel:SearchViewModel = SearchViewModel()
    var refreshBarButton:UIBarButtonItem!
    var selectedLocation:Location? = nil
    @IBOutlet weak var mapView:MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        self.configureUIElements()
         self.configureClosures()
        viewModel.loadLocations()
    }
    
    func configureClosures(){
          
      viewModel.showAlert = { [weak self]
                   (message) in
            GCD.runOnMainThread {
                self?.showAlert(message: message)
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
                 
       }
        
        viewModel.dataUpdated = {
            [weak self] in
            GCD.runOnMainThread {
                self?.showLocations()
                self?.addAnnotations()
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func configureUIElements(){
           self.refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action:#selector(refreshMapView))
                  refreshBarButton.tintColor = UIColor.black
                  navigationItem.rightBarButtonItem = refreshBarButton
                  navigationItem.rightBarButtonItem?.isEnabled = false
        let region = MKCoordinateRegion(.world)
        mapView.setRegion(region, animated: true)
        
    }
    
    @objc func refreshMapView(){
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
        
      case 1:
        let annotation = annotations[annotations.count - 1]
        region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
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
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
          let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
          
          pinView.isEnabled = true
          pinView.canShowCallout = true
          pinView.animatesDrop = false
          pinView.pinTintColor = UIColor.red
          
          let rightButton = UIButton(type: .infoLight)
          rightButton.addTarget(self, action: #selector(showLocationDescription(_:)), for: .touchUpInside)
          pinView.rightCalloutAccessoryView = rightButton
          
          annotationView = pinView
        }
        
        if let annotationView = annotationView {
            
          annotationView.annotation = annotation
        }
        
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
    }

    extension ViewController:LocationDelegate{
        
        func locationDescriptionChanged(_ changedLocation: Location) {
            
            let location = viewModel.locationsArray.filter({$0.latitude == changedLocation.latitude && $0.longitude == changedLocation.longitude}).first
            location?.locationDescription = changedLocation.locationDescription
            try! DiskCareTaker.save(viewModel.locationsArray, to: viewModel.fileName)
            addAnnotations()
            
        }
    }

