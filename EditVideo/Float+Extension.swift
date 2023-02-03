//
//  Float+Extension.swift
//  EditVideo
//
//  Created by tomosia on 07/02/2023.
//

import Foundation

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
