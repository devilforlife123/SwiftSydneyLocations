//
//  UIView+Extensions.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
    return UINib(
      nibName: nibNamed,
      bundle: bundle
    ).instantiate(withOwner: nil, options: nil).first as? UIView
  }
}
