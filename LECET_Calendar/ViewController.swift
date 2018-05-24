//
//  ViewController.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var component = getDateComponents(date: Date())
        
        
        dateComponents.day = 1
        
        
        print(startingRangeOfDay())
    }
}

