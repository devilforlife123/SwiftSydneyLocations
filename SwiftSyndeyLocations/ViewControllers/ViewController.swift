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
    
    @IBOutlet weak var mapView:MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        viewModel.fetchLocations { 
        }
        
        self.configureClosures()
    }
    
    func configureClosures(){
          
      viewModel.showAlert = { [weak self]
                   (message) in
             self?.showAlert(message: message)
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
                 
       }
        
        viewModel.dataUpdated = {
            [weak self] in
              self?.addAnnotations()
              self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func addAnnotations() {
        
            self.mapView.removeAnnotations(self.viewModel.locationsArray)
            self.mapView.addAnnotations(self.viewModel.locationsArray)
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
    
    @objc func showLocationDescription(_ sender: UIButton) {
        
    }
    
}

