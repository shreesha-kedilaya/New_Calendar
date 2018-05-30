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
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var yearMonthButton: UIButton!
    @IBOutlet var weekLabels: [UILabel]!
    
    private(set) var calendarData: CalendarData!
    
    private var flowLayout : CalendarFlowLayout?
    private var scrolledInitially = false
    
    var highlightCurrentDate = true {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout?.itemSize = CGSize(width: calendarCollectionView.frame.size.width / 7, height: calendarCollectionView.frame.size.height / 5)
        scrollInitially()
    }
    
    private func createMonthAndYearLabels() {
        
        yearMonthButton.setTitle("Jan 2016", for: .normal)
        yearMonthButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        yearMonthButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func yearMonthButtonDidClick(_ sender : UIButton) {
        print("Year month button clicked")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func sharedInit() {
        initializeCollectionView()
        createMonthAndYearLabels()
        registerCell()
        setWeekLabelsText()
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
    
    private func setWeekLabelsText() {
        for weekLabel in weekLabels.enumerated() {
            weekLabel.element.text = Week(rawValue: weekLabel.offset + 1)?.name(style: .Three, casingStyle: .AllUpper) ?? ""
            weekLabel.element.textColor = UIColor.white
        }
    }
    
    private func initializeCollectionView() {
        calendarData = CalendarData()
        flowLayout = CalendarFlowLayout()
        if let layout = flowLayout {
            calendarCollectionView.setCollectionViewLayout(layout, animated: true)
        }
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        flowLayout?.scrollDirection = .horizontal
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.backgroundColor = UIColor.black
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let currentSection = Int(floor(targetContentOffset.pointee.x / calendarCollectionView.bounds.width)) + 1
        calendarData.changeCurentSectionTo(section: currentSection)
        
        if currentSection.f >= calendarData.kDefaultNumberOfSections.f {
            
            //set the content offset of the collection view to the initial section after some time say 0.15 seconds to look the scroll animation look smoother
            calendarData.increaseNumberOfIterations()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.3))) {
                self.reloadCollectionViewAttributesFor(position: .forward)
            }
        }else if currentSection <= 1 {
            
            calendarData.decreaseNumberOfIterations()
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
        flowLayout?.currentIterationIndex = calendarData.numberOfIterations
        flowLayout?.invalidateLayout()
    }
}

extension CalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calendarData.kDefaultNumberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell

        cell?.dateButton.setTitle(calendarData.getTheTitleFor(indexPath: indexPath), for: .normal)
        cell?.dateButton.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
        
        if calendarData.isMatchingWithCurrentDateFor(indexPath: indexPath) {
            cell?.dateButton.backgroundColor = UIColor(red: 41/255, green: 150/255, blue: 130/255, alpha: 1)
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 7, height: collectionView.bounds.height / 6)
    }
}

extension CalendarView {
    
    private func changeTheTextOfYearMonthLabel() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.yearMonthButton.alpha = 0
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
                self.yearMonthButton.alpha = 1.0
                if let name = Months(rawValue: self.calendarData.currentMonth)?.name() {
                    self.yearMonthButton.setTitle("\(name) \(self.calendarData.currentYear)", for: .normal)
                }
            })
        }
    }
}
