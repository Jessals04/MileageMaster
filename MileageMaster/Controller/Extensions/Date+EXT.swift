//
//  Date+EXT.swift
//  MileageMaster
//
//  Created by Jesse Watson on 28/04/2024.
//

import Foundation

/**
 Source: https://stackoverflow.com/questions/53356392/how-to-get-day-and-month-from-date-type-swift-4
 */

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
