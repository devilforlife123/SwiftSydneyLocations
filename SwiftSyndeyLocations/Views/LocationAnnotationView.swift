//
//  LocationAnnotationView.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 2/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

private let locationMapPinImage = UIImage(named: "mapPin")!
private let locationMapAnimationTime = 0.5
let resizedCustomPinImage:UIImage = {
      let size = CGSize(width: 50, height: 50)
                        UIGraphicsBeginImageContext(size)
                 locationMapPinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
      return resizedImage
}()

class LocationAnnotationView: MKAnnotationView {
    
    
    weak var locationDetailDelegate: LocationDetailDelegate?
    weak var customCalloutView: LocationView?
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadLocationView() {
                
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height-60
                
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
        
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: locationMapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated {
                    UIView.animate(withDuration: locationMapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() }
                
            }
        }
    }
    
    func loadLocationView() -> LocationView? {
        if let views = Bundle.main.loadNibNamed("LocationView", owner: self, options: nil) as? [LocationView], views.count > 0 {
            let locationView = views.first!
            locationView.delegate = self.locationDetailDelegate
            if let locationAnnotation = annotation as? Location {
                locationView.configureWithLocation(location: locationAnnotation)
            }
            return locationView
        }
        return nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
}
