//
//  CalendarFlowLayout.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class CalendarFlowLayout: UICollectionViewFlowLayout {

    private let kNumberOfVisibleCells = 3
    
    var presentingMonth = 0
    var presentingYear = 0
    var currentIterationIndex = 0
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return addAttributes(forIndexPath: indexPath)
    }
    
    override var collectionViewContentSize: CGSize {
        if let collectionView = collectionView {
            return CGSize(width: collectionView.numberOfSections.f * itemSize.width * 7, height: collectionView.frame.size.height)
        }else {
            return CGSize.zero
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let elements = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var array = [UICollectionViewLayoutAttributes]()
        for index in 0..<elements.count {
            if let attributes = addAttributes(forIndexPath:(elements[index].indexPath)) {
                if elements[index].indexPath.section == 3 {
                    print(elements.count)
                }
                array.append(attributes)
            }
        }
        
        return array
    }
    
    private func addAttributes(forIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: forIndexPath)
        if let collectionView = collectionView {
            let section = forIndexPath.section
            let item = forIndexPath.item
            dateComponents.month = getCurrentMonthFor(section: section)
            dateComponents.year = getCurrentYearFor(section: section)
            
            let firstDay = startingRangeOfDay() - 1
            let numberOfDays = totalDaysForCurrentMonth()
            
            let heightOfItems = collectionView.frame.height / getNumberOfWeek().f

            let xOffset = ( item % 7 == 0) ? (section.f * collectionView.frame.size.width) : (section.f * collectionView.frame.size.width + ( item % 7 ).f * itemSize.width )
            let yOffset = ( item / 7 ).f * heightOfItems
            
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: heightOfItems)
            
//            if section == 3 {
            print("section is \(section)")
                print("indexPath is \(item)")
                print("xOffset is \(xOffset)")
                print(collectionView.numberOfItems(inSection: section))
//            }
            
            if item < firstDay || (item + 1) > (numberOfDays + firstDay) {
                attributes.alpha = 0.5
            }
            
            return attributes
        }
        
        return nil
    }
}

extension CalendarFlowLayout {
    private func getCurrentMonthFor(section : Int) -> Int{
        let retMonth = (section + presentingMonth + rangeOfMonthToBeAdded() - 1) % 12
        return retMonth
    }
    
    private func getCurrentYearFor(section: Int) -> Int {
        let retYear = presentingYear.f + floor((section.f + presentingMonth.f + currentIterationIndex.f + rangeOfMonthToBeAdded().f - 1.f) / 12.f)
        return Int(retYear)
    }
    
    private func rangeOfMonthToBeAdded() -> Int{
        return currentIterationIndex * kNumberOfVisibleCells
    }
}

extension CGFloat {
    var f : CGFloat {
        return self
    }
}
extension Int {
    var f : CGFloat {
        return CGFloat(self)
    }
}

extension Float {
    var f : CGFloat {
        return CGFloat(self)
    }
}

extension Double {
    var f : CGFloat {
        return CGFloat(self)
    }
    
}

