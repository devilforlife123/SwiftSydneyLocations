//
//  EditLocationViewController.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit

protocol LocationDelegate:class{
    
    func locationDescriptionChanged(_ changedLocation:Location)
}

class EditDescriptionViewController:UIViewController{
    
    weak var delegate:LocationDelegate!
    @IBOutlet weak var popupView: UIView!
    @IBAction func cancelButtonPressed(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        location.locationDescription = locationDescriptionTextView.text
        location.name = locationNameTextView.text
        delegate.locationDescriptionChanged(location)
        dismiss(animated: true, completion: nil)
    }
    
    var location: Location! {
       didSet {
         if isViewLoaded {
           updateUI()
         }
       }
     }
    
    @IBOutlet weak var locationDescriptionTextView: UITextView!
    @IBOutlet weak var locationNameTextView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 10
           
        if location != nil {
            updateUI()
        }
    }

    
    func updateUI() {
        if(location.locationDescription == "" || location.locationDescription == nil){
            locationDescriptionTextView.text = "(No Description)"
        }else{
           locationDescriptionTextView.text = location.locationDescription
        }
    }
    
    
    
}
