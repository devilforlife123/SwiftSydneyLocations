//
//  LocationTableViewCell.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 2/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationTableViewCell:UITableViewCell{
    
    @IBOutlet weak var locationImageView:UIImageView!
    @IBOutlet weak var locationName:UILabel!
    @IBOutlet weak var locationDescription:UILabel!
    @IBOutlet weak var distanceFromUser:UILabel!
    var viewModel:SearchViewModel = SearchViewModel.shared
    
    
    var location:Location!{
        didSet{
            updateUI()
        }
    }
    
     override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }

    
    func updateUI(){
        locationName.text = location.name ?? "Default Name"
        locationDescription.text = location.locationDescription ?? "Default Description"
        locationImageView.image = UIImage(named: "places")
        if let data = location.imageData{
            if let image = UIImage(data: data){
                locationImageView.image = image
            }
        }
        let userLocation = CLLocation(latitude: viewModel.userLocation.latitude, longitude: viewModel.userLocation.longitude)
        let locationCoordinate = CLLocation(latitude: location.latitude!, longitude: location.longitude!)
        let difference = userLocation.distance(from: locationCoordinate)
        distanceFromUser.text = String(format: "%.01fkm", difference/1000)
        
        
    }
}
