//
//  NetworkManager.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import Alamofire


class NetworkManager{
    
    static let shared = NetworkManager()
       static let errorMessage = "Something went wrong, Please try again later"
       static let noInternetConnection = "Please check your Internet connection and try again."
    
    func getLocations(completion:@escaping ()->()){
        
    }
}
