//
//  CalendarView.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class CalendarView: UIView {
    
    enum BoundaryPositions {
        
        case forward
        case backward
    }
    
    private var calendarCollectionView: UICollectionView!
    
    private var presentingDay = 0
    private var presentingMonth = 0
    private var presentingYear = 0
    
    private var numberOfIterations = 0
    private let kCellsVisibleToTheUser = 3
    private let kNumberOfDaysInAWeek = 7
    private let kDefaultNumberOfSections = 5
    
    private var currentSection = 0
    private var currentMonth = 0
    private var currentYear = 0
    
    private var flowLayout : CalendarFlowLayout?
    
    var presentingDate = Date() {
        didSet {
            changeTheDateComponent()
            reloadData()
        }
    }
    var highlightCurrentDate = true {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout?.itemSize = CGSize(width: calendarCollectionView.frame.size.width / 7, height: calendarCollectionView.frame.size.height / 5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        initializeCollectionView()
        registerCell()
        
        changeTheDateComponent()
        
        print("--------------------------")
        print("reloaded")
        reloadData()
    }
    
    func reloadData() {
        calendarCollectionView.reloadData()
    }
    
    private func registerCell() {
        calendarCollectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "CalendarCollectionViewCell")
    }
    
    private func initializeCollectionView() {
        flowLayout = CalendarFlowLayout()
        
        calendarCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout!)
        addSubview(calendarCollectionView)
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintsToView()
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        (calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        calendarCollectionView.isPagingEnabled = true
    }
    
    private func addConstraintsToView() {
        let leading = NSLayoutConstraint(item: calendarCollectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: calendarCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: calendarCollectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: calendarCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        addConstraints([leading, trailing, top, bottom])
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        currentSection = Int(floor(targetContentOffset.pointee.x / calendarCollectionView.bounds.width)) + 1
        
        currentMonth = getCurrentMonthFor(section: currentSection - 1) + 1
        currentYear = getCurrentYearFor(section: currentSection - 1)
        
        if currentSection.f >= kDefaultNumberOfSections.f {
            
            //set the content offset of the collection view to the initial section after some time say 0.15 seconds to look the scroll animation look smoother
            numberOfIterations += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.3))) {
                self.reloadCollectionViewAttributesFor(position: .forward)
            }
        }else if currentSection <= 1 {
            
            numberOfIterations -= 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.3))) {
                self.reloadCollectionViewAttributesFor(position: .backward)
            }
        }
    }
    
    private func reloadCollectionViewAttributesFor(position : BoundaryPositions){
        
        //dispatch every UI updates in the main queue
        
        var positionPoint = CGPoint.zero
        switch position {
        case .backward:
            
            let contentSize = self.calendarCollectionView.contentSize
            calendarCollectionView.setContentOffset(CGPoint(x: contentSize.width.f - 2 * calendarCollectionView.frame.width, y: 0.f), animated: false) //2* collectionViewWidth because to the second section the width = 2 * the collection view width
            
        case .forward:
            
            positionPoint = CGPoint(x: self.calendarCollectionView.bounds.width, y: 0.f)
            calendarCollectionView.setContentOffset(positionPoint, animated: false)
        }
        
        reloadData()
        flowLayout?.currentIterationIndex = self.numberOfIterations
        flowLayout?.invalidateLayout()
    }
}

extension CalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return kDefaultNumberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dateComponents.day = 1
        dateComponents.month = getCurrentMonthFor(section: section)
        dateComponents.year = getCurrentYearFor(section: section)
        let numberOfItems = totalDaysForCurrentMonth()
        
        return numberOfItems
        
    }
    
    func isPresentDateFor(indexPath : IndexPath) -> Bool {
        let currentIterationInfo = getTheCurrentIterationIndexForCurrentDate()
        return (numberOfIterations == currentIterationInfo.0 && indexPath == (currentIterationInfo.1) && highlightCurrentDate)
    }
    
    //Gives the current date index and the iteration index for the present day
    private func getTheCurrentIterationIndexForCurrentDate() -> (Int, IndexPath) {
        
        _ = getDateComponents(date: presentingDate)
        let year1 = dateComponents.year
        let month1 = dateComponents.month
        
        _ = getDateComponents(date: Date())
        let year2 = dateComponents.year
        let day2 = dateComponents.day
        let month2 = dateComponents.month
        
        let yearDifference = (year1 ?? 0) - (year2 ?? 0)
        let differenceBWMonths = (yearDifference * (12 - (month1 ?? 0) + 12 - (month2 ?? 0)))
        
        let currentNumberOfIterationForCurrentDay = floor(differenceBWMonths.f / 3)
        
        let currentMonthIndex = differenceBWMonths % 3 + 1
        let indexPath = IndexPath(item: (day2 ?? 0) - 1, section: currentMonthIndex)
        
        return (Int(currentNumberOfIterationForCurrentDay), indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell
        cell?.dateButton.setTitle("\(indexPath.item + 1)", for: .normal)
        
        if isPresentDateFor(indexPath: indexPath) {
            cell?.dateButton.backgroundColor = .blue
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension CalendarView {
    
    private func getCurrentMonthFor(section : Int) -> Int{
        let retMonth = (section + presentingMonth + rangeOfMonthToBeAdded() - 1) % 12
        return retMonth
    }
    
    private func getCurrentYearFor(section: Int) -> Int {
            let retYear = presentingYear.f + floor((section.f + presentingMonth.f + rangeOfMonthToBeAdded().f - 1.f) / 12.f)
        return Int(retYear)
    }
    
    private func rangeOfMonthToBeAdded() -> Int{
        return numberOfIterations * kCellsVisibleToTheUser
    }
    
    private func changeTheDateComponent() {
        let dateComponentsCurrent = getDateComponents(date: presentingDate)
        presentingDay = dateComponentsCurrent.day ?? 0
        presentingMonth = dateComponentsCurrent.month ?? 0
        presentingYear = dateComponentsCurrent.year ?? 0
        
        currentMonth = presentingMonth
        currentYear = presentingYear
        
        flowLayout?.presentingMonth = presentingMonth
        flowLayout?.presentingYear = presentingYear
    }
}
