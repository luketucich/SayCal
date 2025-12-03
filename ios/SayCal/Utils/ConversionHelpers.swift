import Foundation

// MARK: - Weight Conversions

extension Double {
    /// Converts kilograms to pounds
    var kgToLbs: Double { self * 2.20462 }

    /// Converts pounds to kilograms
    var lbsToKg: Double { self / 2.20462 }

    /// Converts Double to Int
    var int: Int { Int(self) }
}

// MARK: - Height Conversions

extension Int {
    /// Converts centimeters to inches
    var cmToInches: Int {
        (Double(self) / 2.54).rounded(.toNearestOrEven).int
    }

    /// Converts inches to centimeters
    var inchesToCm: Int {
        (Double(self) * 2.54).rounded(.toNearestOrEven).int
    }

    /// Converts centimeters to feet and inches tuple
    var cmToFeetAndInches: (feet: Int, inches: Int) {
        let totalInches = self.cmToInches
        return (feet: totalInches / 12, inches: totalInches % 12)
    }
}

/// Converts feet and inches to centimeters
func feetAndInchesToCm(feet: Int, inches: Int) -> Int {
    let totalInches = (feet * 12) + inches
    return totalInches.inchesToCm
}
