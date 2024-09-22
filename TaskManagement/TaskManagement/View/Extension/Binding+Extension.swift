//
//  Binding+Extension.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 22/09/24.
//

import Foundation
import SwiftUI

extension Binding {
    func isNotNil<T>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in
            wrappedValue = nil
        })
    }
}
