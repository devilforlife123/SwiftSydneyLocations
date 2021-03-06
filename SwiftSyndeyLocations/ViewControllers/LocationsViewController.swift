//
//  LocationsViewController.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationsViewController:UITableViewController{
    
    
    var viewModel:SearchViewModel = SearchViewModel.shared
    var sortedArray:[Location]!
    var userCoreLocation:CLLocation!
    var selectedLocation:Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func arrangeLocationsWithDistance(){
        sortedArray = []
        sortedArray = viewModel.locationsArray.sorted { (location1, location2) -> Bool in
            let clLocation1 = CLLocation(latitude: location1.latitude!, longitude: location1.longitude!)
            let clLocation2 = CLLocation(latitude: location2.latitude!, longitude: location2.longitude!)
            return clLocation1.distance(from:userCoreLocation) < clLocation2.distance(from: userCoreLocation)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userCoreLocation = CLLocation(latitude:viewModel.userLocation.latitude,longitude:viewModel.userLocation.longitude)
        self.arrangeLocationsWithDistance()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        let locationModel = sortedArray[indexPath.row]
           cell.location = locationModel
            return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditDescription"{
            let controller = segue.destination as! EditDescriptionViewController
            controller.delegate = self
            if let indexPath = self.tableView.indexPathForSelectedRow{
                controller.location = sortedArray[indexPath.row]
            }else{
                controller.location = nil
            }
        }
    }
}

extension LocationsViewController:LocationDelegate{
      
      func locationDeleted(_ deletedLocation:Location){
          viewModel.locationsArray.removeAll { (location) -> Bool in
              return location == deletedLocation
          }
          try! DiskCareTaker.save(viewModel.locationsArray, to: viewModel.fileName)
      }
      
     func locationDetailsChanged(_ changedLocation: Location) {
             
         let location = viewModel.locationsArray.filter({$0 == changedLocation}).first
         location?.locationDescription = changedLocation.locationDescription
         location?.name = changedLocation.name
         location?.imageData = changedLocation.imageData
         try! DiskCareTaker.save(viewModel.locationsArray, to: viewModel.fileName)
             
      }
  }
