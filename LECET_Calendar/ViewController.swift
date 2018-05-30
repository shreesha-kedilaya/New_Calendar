//
//  ViewController.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    private var calendarView: CalendarView?
    override func viewDidLoad() {
        super.viewDidLoad()
                
        calendarView = UINib(nibName: "CalendarView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CalendarView
        calendarView?.translatesAutoresizingMaskIntoConstraints = false
        if let calendarView = calendarView {
            containerView.addSubview(calendarView)
            addConstraintsToCalendar()
        }
        
        view.backgroundColor = UIColor.black
        
        calendarView?.backgroundColor = UIColor.black
        
        dateComponents.day = 1
        
        print(startingRangeOfDay())
    }
    
    private func addConstraintsToCalendar() {
        if let calendarView = calendarView {
            let leading = NSLayoutConstraint(item: calendarView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: calendarView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: calendarView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: calendarView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)

            containerView.addConstraints([leading, trailing, top, bottom])
        }
    }
}

