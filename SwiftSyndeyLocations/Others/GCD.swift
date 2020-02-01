//
//  GCD.swift
//  SwiftSyndeyLocations
//
//  Created by suraj poudel on 1/2/20.
//  Copyright © 2020 suraj poudel. All rights reserved.
//

import Foundation

class GCD{
    
    static func runAsync(closure:@escaping()->()){
        DispatchQueue.global(qos: .userInitiated).async {
            closure()
        }
    }
    
    static func runOnMainThread(closure:@escaping()->()){
        DispatchQueue.main.async {
            closure()
        }
    }
    
    static func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
      DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
    }
}

