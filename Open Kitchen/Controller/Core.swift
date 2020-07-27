//
//  Core.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-07-03.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    ///
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
        
    }
}
