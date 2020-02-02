//
//  LocationView.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 2/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

protocol LocationDetailDelegate:class{
    func detailsShownForLocation(location: Location)
}
class LocationView: UIView {
    // outlets
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationDescription: UILabel!
    @IBOutlet weak var seeDetailsButton: UIButton!
    
    var location: Location!
    weak var delegate:LocationDetailDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        let calculatedHeight = 180+(locationName.frame.size.height + locationDescription.frame.size.height+seeDetailsButton.frame.size.height)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height:calculatedHeight)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    
    @IBAction func seeDetails(_ sender: Any) {
        delegate.detailsShownForLocation(location:self.location)
    }
    
    
    func configureWithLocation(location:Location) {
        self.location = location
        if let data = location.imageData{
            if let image = UIImage(data: data){
                locationImageView.image = image
            }
        }
        
        locationName.text = location.name ?? "Default Name"
        locationDescription.text = location.locationDescription ?? "Default Description"
        
    }

 
}
