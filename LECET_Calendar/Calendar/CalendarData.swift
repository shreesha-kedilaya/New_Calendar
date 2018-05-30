////
////  CalendarData.swift
////  LECET_Calendar
////
////  Created by Shreesha on 30/05/18.
////  Copyright © 2018 Shreesha. All rights reserved.
////
//
//import Foundation
//
//extension String {
//
//    subscript (i: Int) -> Character {
//        return self[self.index(self.startIndex, offsetBy: i)]
//    }
//
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }
//
//    subscript (r: CountableClosedRange<Int>) -> String {
//        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
//        let end = self.index(self.startIndex, offsetBy: r.upperBound)
//        return String(self[Range(start ..< end)])
//    }
//}
//
//
//enum Months : Int {
//    case January = 1,
//    February,
//    March,
//    April,
//    May,
//    June,
//    July,
//    August,
//    September,
//    October,
//    November,
//    December = 0
//
//    func name() -> String {
//        return "\(self)"
//    }
//}
//
//enum Week : Int{
//    case Sunday = 1,
//    Monday,
//    Tuesday,
//    Wednesday,
//    Thursday,
//    Friday,
//    Saturday
//
//    func name(style : WeekStyles, casingStyle : CasingStyle) -> String {
//
//        var range = 0...0
//        switch style {
//        case .One:
//            range = 0...0
//        case .Two:
//            range = 0...1
//        case .Three :
//            range = 0...2
//        default :
//            range = 0...("\(self)".count - 1)
//        }
//
//        return casingStyle.letter(forString: "\(self)"[range])
//    }
//}
//enum WeekStyles : Int{
//    case One = 10,
//    Two,
//    Three,
//    Full
//}
//
//enum CasingStyle {
//    case FirstLetterUpper,
//    AllUpper,
//    AllLower
//
//    func letter(forString : String) -> String {
//        switch self {
//        case .FirstLetterUpper:
//            return forString
//        case .AllLower:
//            return forString.lowercased()
//        case .AllUpper :
//            return forString.uppercased()
//        }
//    }
//}
//
//struct DateElements {
//    var day: Int
//    var month: Int
//    var year: Int
//}
//
//func ==(lhs: DateElements, rhs: DateElements) -> Bool {
//    if lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year {
//        return true
//    }
//
//    return false
//}
//
//class CalendarData {
//
//    private var presentingDay = 0
//    private var presentingMonth = 0
//    private var presentingYear = 0
//
//    private var numberOfIterations = 0
//    private let kCellsVisibleToTheUser = 3
//    private let kNumberOfDaysInAWeek = 7
//    private let kDefaultNumberOfSections = 5
//
//    private var currentSection = 0
//    private var currentMonth = 0
//    private var currentYear = 0
//
//    private func convertDateIntoDateElements(date: Date) -> DateElements {
//        let dateComponents = getDateComponents(date: date)
//        let dateElements = DateElements(day: dateComponents.day ?? 0, month: dateComponents.month ?? 0 , year: dateComponents.year ?? 0)
//        return dateElements
//    }
//
//    private func isMatchingWithCurrentDateFor(indexPath: IndexPath) -> Bool {
//
//        _ = getDateComponents(date: Date())
//        let year = dateComponents.year ?? 0
//        let day = dateComponents.day ?? 0
//        let month = dateComponents.month ?? 0
//
//        let currentYear = getCurrentYearFor(section: indexPath.section)
//        let currentMonth = getCurrentMonthFor(section: indexPath.section)
//
//        dateComponents.month = currentMonth
//        dateComponents.year = currentYear
//
//        let firstDay = startingRangeOfDay() - 1
//
//        if currentMonth == month && currentYear == year && day == (indexPath.item + 1 - firstDay) {
//            return true
//        }
//
//        return false
//    }
//
//    private func getTheTitleFor(indexPath: IndexPath) -> String {
//        dateComponents.month = getCurrentMonthFor(section: indexPath.section)
//        dateComponents.year = getCurrentYearFor(section: indexPath.section)
//
//        let firstDay = startingRangeOfDay() - 1
//        let numberOfDays = totalDaysForCurrentMonth()
//
//        dateComponents.month = getCurrentMonthFor(section: indexPath.section - 1)
//        dateComponents.month = getCurrentMonthFor(section: indexPath.section - 1)
//
//        let previousMonthDays = totalDaysForCurrentMonth()
//
//        var currentDay = 0
//
//        if indexPath.item < firstDay {
//            currentDay = indexPath.item + 1 - firstDay + previousMonthDays
//        } else if indexPath.item + 1 > (numberOfDays + firstDay) {
//            currentDay = indexPath.item + 1 - numberOfDays - firstDay
//        } else {
//            currentDay = indexPath.item + 1 - firstDay
//        }
//
//        return "\(currentDay)"
//    }
//
//    private func changeTheDateComponent() {
//        let dateComponentsCurrent = getDateComponents(date: presentingDate)
//        presentingDay = dateComponentsCurrent.day ?? 0
//        presentingMonth = dateComponentsCurrent.month ?? 0
//        presentingYear = dateComponentsCurrent.year ?? 0
//
//        currentMonth = presentingMonth
//        currentYear = presentingYear
//
//        flowLayout?.presentingMonth = presentingMonth
//        flowLayout?.presentingYear = presentingYear
//    }
//
//    private func getCurrentMonthFor(section : Int) -> Int{
//        let retMonth = (section + presentingMonth + rangeOfMonthToBeAdded() - 1) % 12
//        return retMonth
//    }
//
//    private func getCurrentYearFor(section: Int) -> Int {
//        let retYear = presentingYear.f + floor((section.f + presentingMonth.f + rangeOfMonthToBeAdded().f - 1.f) / 12.f)
//        return Int(retYear)
//    }
//
//    private func rangeOfMonthToBeAdded() -> Int{
//        return numberOfIterations * kCellsVisibleToTheUser
//    }
//}
