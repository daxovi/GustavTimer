//
//  String+Extension.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 03.01.2026.
//

import Foundation

extension String {
    /// Vrátí lokalizovaný řetězec podle klíče (self).
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Vrátí lokalizovaný řetězec s formátováním (pro argumenty jako %s, %d).
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
