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
    }
}
extension ViewController:MKMapViewDelegate{
    
}

