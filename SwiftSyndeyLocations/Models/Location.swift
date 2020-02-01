//
//  Location.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import MapKit

class Location:NSObject,Codable,MKAnnotation{

    var name:String?
    var locationDescription:String? = nil
    var latitude:Double?
    var longitude:Double?
    var imageData:Data?
    var isAdded:Bool?
       
    enum CodingKeys:String,CodingKey{
           case name
           case latitude = "lat"
           case longitude = "lng"
           case description = "description"
           case imageData
           case isAdded
    }
    
    init(coordinate:CLLocationCoordinate2D){
        self.latitude   = coordinate.latitude
        self.longitude  = coordinate.longitude
        self.name = "Default Location"
        self.locationDescription = "Default Description"
        self.imageData = UIImage(named: "Flag")!.pngData()!
        self.isAdded = true
    }
       
    required init(from decoder:Decoder) throws{
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.name = try container.decodeIfPresent(String.self,forKey:.name)
            self.latitude = try container.decodeIfPresent(Double.self,forKey:.latitude)
            self.longitude = try container.decodeIfPresent(Double.self,forKey:.longitude)
            self.locationDescription = try container.decodeIfPresent(String.self,forKey:.description)
            self.imageData = try container.decodeIfPresent(Data.self, forKey:.imageData)
            self.isAdded = try container.decodeIfPresent(Bool.self,forKey:.isAdded)
    }
       
       func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
                 try container.encode(name, forKey: .name)
                 try container.encode(locationDescription, forKey: .description)
                 try container.encode(latitude,forKey:.latitude)
                try container.encode(longitude,forKey: .longitude)
                try container.encode(imageData,forKey:.imageData)
                try container.encode(isAdded,forKey: .isAdded)
       }
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
}
extension Location{

     var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude ?? 0.0, longitude ?? 0.0)
    }

    var title: String? {
      return name
    }

    public var subtitle: String? {
        return (locationDescription != nil) ? locationDescription: "(No Description)"
    }
}
