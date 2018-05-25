//
//  DateComponents.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation

var dateComponents = DateComponents()
var calendar = Calendar.current
var dateFormatter = DateFormatter()

func getDateComponents(date : Date) -> DateComponents {
    dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: date)
    return dateComponents
}

private func getActualDatefromCalendar() -> Date {
    if let date = calendar.date(from: dateComponents) {
        return date
    }
    return Date()
}

func totalDaysForCurrentMonth() -> Int {
    if let total = calendar.range(of: .day, in: .month, for: getActualDatefromCalendar())?.count {
        return total
    }
    
    return 0
}

func startingRangeOfDay() -> Int {
    dateComponents.day = 1
    if let weekday = getDateComponents(date: getActualDatefromCalendar()).weekday {
        return weekday
    }
    
    return 0
}

func getNumberOfWeek() -> Int {
//    if let total = calendar.range(of: .weekOfMonth, in: .month, for: getActualDatefromCalendar())?.count {
//        return total
//    }
    
    return 5
}
