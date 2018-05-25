//
//  CalendarView.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
}


enum Months : Int {
    case January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
    
    func name() -> String {
        return "\(self)"
    }
}

enum Week : Int{
    case Sunday = 1,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
    
    func name(style : WeekStyles, casingStyle : CasingStyle) -> String {
        
        var range = 0...0
        switch style {
        case .One:
            range = 0...0
        case .Two:
            range = 0...1
        case .Three :
            range = 0...2
        default :
            range = 0...("\(self)".count - 1)
        }
        
        return casingStyle.letter(forString: "\(self)"[range])
    }
}
enum WeekStyles : Int{
    case One = 10,
    Two,
    Three,
    Full
}

enum CasingStyle {
    case FirstLetterUpper,
    AllUpper,
    AllLower
    
    func letter(forString : String) -> String {
        switch self {
        case .FirstLetterUpper:
            return forString
        case .AllLower:
            return forString.lowercased()
        case .AllUpper :
            return forString.uppercased()
        }
    }
}

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
    private var yearMonthButton : UIButton!
    private var weekLabels : [UILabel]!
    
    private var flowLayout : CalendarFlowLayout?
    private var scrolledInitially = false
    
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
        scrollInitially()
    }
    
    private func createMonthAndYearLabels() {
        
        if yearMonthButton == nil {
            
            yearMonthButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2, height: 30))
            yearMonthButton.setTitle("Jan 2016", for: .normal)
            
            yearMonthButton.titleLabel?.textColor = UIColor.white
            yearMonthButton.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
            yearMonthButton.translatesAutoresizingMaskIntoConstraints = false
            yearMonthButton.titleLabel?.textAlignment = .center
            yearMonthButton.addTarget(self, action: #selector(CalendarView.yearMonthButtonDidClick(_:)), for: .touchUpInside)
            addSubview(yearMonthButton)
            addConstraintToMonthAndYearLabels()
        }
    }
    
    @objc func yearMonthButtonDidClick(_ sender : UIButton) {
        print("Year month button clicked")
    }
    
    private func addConstraintToMonthAndYearLabels() {
        
        let topConstraint = NSLayoutConstraint(item: yearMonthButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: yearMonthButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: yearMonthButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        addConstraints([topConstraint, leadingConstraint])
        yearMonthButton.addConstraint(heightConstraint)
    }
    
    private func createWeekLabels() {
        
        if let weekLabels = weekLabels {
            for label in weekLabels {
                label.removeFromSuperview()
            }
        }
        weekLabels = []
        
        for index in 0..<kNumberOfDaysInAWeek {
            let label = UILabel()
            if let text = Week(rawValue: index + 1)?.name(style: .Three, casingStyle: .AllUpper) {
                label.text = text
            }
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
            label.frame = CGRect(x: index.f * bounds.width / kNumberOfDaysInAWeek.f , y: 0, width: bounds.width / kNumberOfDaysInAWeek.f, height: 30)
            addSubview(label)
            
            
            //adding constraint to week labels
            var topConstraint : NSLayoutConstraint
            var bottomConstraint : NSLayoutConstraint
            var leadingConstraint : NSLayoutConstraint
            var trailingConstraint : NSLayoutConstraint?
            
            switch index {
            //first item
            case 0:
                
                topConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: yearMonthButton, attribute: .bottom, multiplier: 1, constant: 10)
                bottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: calendarCollectionView, attribute: .top, multiplier: 1, constant: 0)
                leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
                //No trailing constraint required
                
            //Last label
            case kNumberOfDaysInAWeek-1:
                
                topConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: yearMonthButton, attribute: .bottom, multiplier: 1, constant: 10)
                bottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: calendarCollectionView, attribute: .top, multiplier: 1, constant: 0)
                leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem:weekLabels[index-1] , attribute: .trailing, multiplier: 1, constant: 0)
                trailingConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
                
            default :
                
                topConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: yearMonthButton, attribute: .bottom, multiplier: 1, constant: 10)
                bottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: calendarCollectionView, attribute: .top, multiplier: 1, constant: 0)
                leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: weekLabels[index-1], attribute: .trailing, multiplier: 1, constant: 0)
                
            }
            
            let widthAttribute = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.width / kNumberOfDaysInAWeek.f)
            widthAttribute.priority = UILayoutPriority.defaultHigh
            if let trailingConstraint = trailingConstraint {
                addConstraint(trailingConstraint)
            }
            addConstraints([leadingConstraint,topConstraint,bottomConstraint])
            label.addConstraint(widthAttribute)
            weekLabels.append(label)
        }
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
        createMonthAndYearLabels()
        createWeekLabels()
        registerCell()
        
        changeTheDateComponent()
        
        print("--------------------------")
        print("reloaded")
        reloadData()
    }
    
    private func scrollInitially() {
        if !scrolledInitially {
            calendarCollectionView.setContentOffset(CGPoint(x: calendarCollectionView.bounds.width, y: 0.f), animated: false)
            scrolledInitially = true
        }
    }
    
    func reloadData() {
        calendarCollectionView.reloadData()
        changeTheTextOfYearMonthLabel()
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
        let bottom = NSLayoutConstraint(item: calendarCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        addConstraints([leading, trailing, bottom])
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
        
        changeTheTextOfYearMonthLabel()
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
        return 35
    }
    
    //Gives the current date index and the iteration index for the present day
    private func isMatchingWithCurrentDateFor(indexPath: IndexPath) -> Bool {
        
        _ = getDateComponents(date: Date())
        let year = dateComponents.year ?? 0
        let day = dateComponents.day ?? 0
        let month = dateComponents.month ?? 0
        
        let currentYear = getCurrentYearFor(section: indexPath.section)
        let currentMonth = getCurrentMonthFor(section: indexPath.section)
        
        dateComponents.month = currentMonth
        dateComponents.year = currentYear
        
        let firstDay = startingRangeOfDay() - 1
        
        if currentMonth == month && currentYear == year && day == (indexPath.item + 1 - firstDay) {
            return true
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell

        cell?.dateButton.setTitle(getTheTitleFor(indexPath: indexPath), for: .normal)
        cell?.dateButton.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
        
        if isMatchingWithCurrentDateFor(indexPath: indexPath) {
            cell?.dateButton.backgroundColor = .blue
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    private func getTheTitleFor(indexPath: IndexPath) -> String {
        dateComponents.month = getCurrentMonthFor(section: indexPath.section)
        dateComponents.year = getCurrentYearFor(section: indexPath.section)
        
        let firstDay = startingRangeOfDay() - 1
        let numberOfDays = totalDaysForCurrentMonth()
        
        if dateComponents.month == 6 {
            print("Here we are")
        }
        
        dateComponents.month = getCurrentMonthFor(section: indexPath.section - 1)
        dateComponents.month = getCurrentMonthFor(section: indexPath.section - 1)
        let previousMonthDays = totalDaysForCurrentMonth()
        
        var currentDay = 0
        
        if indexPath.item < firstDay {
            currentDay = indexPath.item + 1 - firstDay + previousMonthDays
        } else if indexPath.item + 1 > (numberOfDays + firstDay) {
            currentDay = indexPath.item + 1 - numberOfDays - firstDay
            print(currentDay)
        } else {
            currentDay = indexPath.item + 1 - firstDay
        }
        
        return "\(currentDay)"
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
    
    private func changeTheTextOfYearMonthLabel() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.yearMonthButton.alpha = 0
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
                self.yearMonthButton.alpha = 1.0
                if let name = Months(rawValue: self.currentMonth)?.name() {
                    self.yearMonthButton.setTitle("\(name) \(self.currentYear)", for: .normal)
                }
            })
        }
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
