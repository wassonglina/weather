//
//  DateExtension.swift
//  weather
//
//  Created by Lina on 2/22/22.
//

import Foundation


extension Date {

    func isBetween(with sunrise: Date, with sunset: Date) -> Bool {

        if self > sunrise && self < sunset {
            return false
        }
        return true
    }

}


