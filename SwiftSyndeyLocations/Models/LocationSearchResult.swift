//
//  LocationSearchResult.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation

struct LocationSearchResult:Codable{
    
    let updated:String?
    let locations:[Location]?
    
    enum CodingKeys:String,CodingKey{
        case updated = "updated"
        case locations = "locations"
        
    }
    
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           self.updated = try container.decodeIfPresent(String.self, forKey: .updated)
           self.locations = try container.decodeIfPresent([Location].self, forKey: .locations)
           
       }
    
    
}
