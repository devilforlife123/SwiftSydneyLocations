//
//  NetworkManager.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import Alamofire

struct API{
    static let urlAddress = "https://s3-ap-southeast-2.amazonaws.com/com-cochlear-sabretooth-takehometest/locations.json"
}


class NetworkManager{
    
    static let shared = NetworkManager()
       static let errorMessage = "Something went wrong, Please try again later"
       static let noInternetConnection = "Please check your Internet connection and try again."
    
    func getLocations(completion:@escaping (Result<Data>)->()){
        guard (Reachability.currentReachabilityStatus != .notReachable)else{
                                return
                                    completion(.Failure(NetworkManager.noInternetConnection))
                      }
        
        Alamofire.request(API.urlAddress, method: .get,encoding: JSONEncoding.default).responseJSON { (response) in
                   debugPrint(response)

                   guard let data = response.data else {
                       return completion(.Failure(response.error?.localizedDescription ?? NetworkManager.errorMessage))
                   }

                   let iSOLatin1Stringresponse = String(data: data, encoding: String.Encoding.isoLatin1)
                   guard let dataUTF8Format = iSOLatin1Stringresponse?.data(using: String.Encoding.utf8) else{
                       return completion(.Failure("Could not convert data to UTF-8 Format"))
                   }

                   return completion(.Success(dataUTF8Format))
        }
    }
}
