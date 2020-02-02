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
    
    func locationDetailsChanged(_ changedLocation:Location)
    func locationDeleted(_ deletedLocation:Location)
}


class EditDescriptionViewController:UITableViewController{
    
    weak var delegate:LocationDelegate!
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
         navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender:Any){
        let alertController = UIAlertController(title: title, message: "Do you want to Delete the Location?", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title:NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) {(action) in
                    self.delegate.locationDeleted(self.location)
                    self.navigationController?.popViewController(animated: true)
                }
                let closeAction = UIAlertAction(title:NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default) {(action) in

                }
                alertController.addAction(okAction)
                alertController.addAction(closeAction)
                present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        location.locationDescription = locationDescriptionTextView.text
        location.name = locationNameTextView.text
        delegate.locationDetailsChanged(location)
        navigationController?.popViewController(animated: true)
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
        
        if location != nil {
            updateUI()
        }
    }
    
    func show(image: UIImage) {
      imageView.image = image
      imageView.isHidden = false
      imageHeight.constant = 260
      tableView.reloadData()
    }

    
    func updateUI() {
        if(location.locationDescription == "" || location.locationDescription == nil){
            locationDescriptionTextView.text = "(No Description)"
        }else{
           locationDescriptionTextView.text = location.locationDescription
        }
        
        locationNameTextView.text = location.name 
        
        latitudeLabel.text = String(format: "%.8f", location.latitude ?? 0.0)
        longitudeLabel.text = String(format: "%.8f", location.longitude ?? 0.0)
        if let data = location.imageData{
            if let image = UIImage(data: data){
                show(image: image)
            }
        }else{
            if let image = UIImage(named: "places"){
                show(image:image)
            }
        }
    }
    
     override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       let selection = UIView(frame: CGRect.zero)
       selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
       cell.selectedBackgroundView = selection
        if(location.isAdded == true ){
            locationNameTextView.isEditable = true
        }
     }
     
     override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
         return indexPath
       } else {
         return nil
       }
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       if indexPath.section == 0 && indexPath.row == 0 {
         locationNameTextView.becomeFirstResponder()
       } else if indexPath.section == 1 && indexPath.row == 0{
        locationDescriptionTextView.becomeFirstResponder()
       }
        else if indexPath.section == 2 && indexPath.row == 0 {
         tableView.deselectRow(at: indexPath, animated: true)
         pickPhoto()
       }
     }
}
extension EditDescriptionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = self.view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func choosePhotoFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func pickPhoto() {
    if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  
  func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(actCancel)
    
    let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
      self.takePhotoWithCamera()
    })
    alert.addAction(actPhoto)
    
    let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
      self.choosePhotoFromLibrary()
    })
    alert.addAction(actLibrary)
    
    present(alert, animated: true, completion: nil)
  }
  
  // MARK:- Image Picker Delegates
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    if let theImage = image {
        let data = theImage.jpegData(compressionQuality: 0.5)
        location.imageData = data
      show(image: theImage)
        delegate.locationDetailsChanged(location)
        
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

