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
       
    enum CodingKeys:String,CodingKey{
           case name
           case latitude = "lat"
           case longitude = "lng"
           case description = "description"
    }
       
    required init(from decoder:Decoder) throws{
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.name = try container.decodeIfPresent(String.self,forKey:.name)
            self.latitude = try container.decodeIfPresent(Double.self,forKey:.latitude)
            self.longitude = try container.decodeIfPresent(Double.self,forKey:.longitude)
            self.locationDescription = try container.decodeIfPresent(String.self,forKey:.description)
       }
       
       func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
                 try container.encode(name, forKey: .name)
                 try container.encode(locationDescription, forKey: .description)
                 try container.encode(latitude,forKey:.latitude)
                try container.encode(longitude,forKey: .longitude)
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
