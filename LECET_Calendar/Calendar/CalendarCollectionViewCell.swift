//
//  CalendarCollectionViewCell.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    var dateButton: UIButton!
    var widthConstraint: NSLayoutConstraint!
    var aspectRatioConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func addSubviewConstraints() {
        let centerX = NSLayoutConstraint(item: dateButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: dateButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        widthConstraint = NSLayoutConstraint(item: dateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        aspectRatioConstraint = NSLayoutConstraint(item: dateButton, attribute: .width, relatedBy: .equal, toItem:dateButton, attribute: .height, multiplier: 1, constant: 0)
        
        addConstraints([centerY, centerX])
        dateButton.addConstraints([widthConstraint, aspectRatioConstraint])
    }
    
    private func sharedInit() {
        dateButton = UIButton(frame: bounds)
        dateButton.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
        addSubview(dateButton)
        dateButton.addTarget(self, action: #selector(CalendarCollectionViewCell.dateButtonClicked(sender:)), for: .touchUpInside)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        addSubviewConstraints()
        dateButton.layer.cornerRadius = 20
        dateButton.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let minimumDimension = min(bounds.width, bounds.height)
        
        dateButton.removeConstraint(widthConstraint)
        dateButton.removeConstraint(aspectRatioConstraint)
        
        widthConstraint = NSLayoutConstraint(item: dateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minimumDimension - 2)
        aspectRatioConstraint = NSLayoutConstraint(item: dateButton, attribute: .width, relatedBy: .equal, toItem:dateButton, attribute: .height, multiplier: 1, constant: 0)
        
        dateButton.addConstraints([widthConstraint, aspectRatioConstraint])
        dateButton.layer.cornerRadius = widthConstraint.constant / 2
        dateButton.layer.masksToBounds = true
    }
    
    @objc func dateButtonClicked(sender: UIButton) {
        
    }
}
