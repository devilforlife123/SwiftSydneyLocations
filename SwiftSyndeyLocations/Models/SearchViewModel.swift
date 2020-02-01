//
//  SearchViewModel.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation

class SearchViewModel{
    
    let fileName = "locationData"
    var showAlert:((String)->())?
    var locationsArray = [Location]()
    var dataUpdated:(()->())?
    
    func loadLocations(){
        if let locations = try? DiskCareTaker.retrieve([Location].self, from: fileName){
            locationsArray.append(contentsOf: locations)
            self.dataUpdated?()
        }else{
            self.fetchLocations {
                if(self.locationsArray.count > 0){
                    try! self.save()
                    self.dataUpdated?()
                }
            }
        }
    }
    
    public func save()throws{
           try DiskCareTaker.save(locationsArray,to:fileName)
       }
       
    
    func fetchLocations(completion:@escaping()->()){
        self.request { locations in
            
            switch locations{
            case .Success(let locationResult):
                if let locationResult = locationResult{
                  self.locationsArray = []
                  self.locationsArray.append(contentsOf: locationResult.locations ?? [])
                  self.dataUpdated?()
                }
                completion()
            case .Failure(let message):
                  self.showAlert?(message)
                completion()
            case .Error(let error):
                self.showAlert?(error)
                completion()
            }
            
        }
    }
        
    func request(completion:@escaping (Result<LocationSearchResult?>)->()){
        NetworkManager.shared.getLocations { result in
            switch result{
            case .Success(let responseData):
                if let model = self.processResponse(responseData){
                    return completion(.Success(model))
                    
                }else {
                    return completion(.Failure(NetworkManager.errorMessage))
                }
            case .Failure(let message):
                return completion(.Failure(message))
            case .Error(let error):
                return completion(.Failure(error))
            }
        }
    }
        
    func processResponse(_ data:Data)->LocationSearchResult?{
           do{
               let decoder = JSONDecoder()
               let locationData = try decoder.decode(LocationSearchResult.self, from: data)
               return locationData
           }catch let err {
               print("Err", err)
               return nil
           }
       }
}
