//
//  SearchViewModel.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation

class SearchViewModel{
    
    func fetchLocations(completion:@escaping()->()){
             self.request { 
        }
    }
        
    func request(completion:@escaping ()->()){
        NetworkManager.shared.getLocations { result in

            }
    }
}
