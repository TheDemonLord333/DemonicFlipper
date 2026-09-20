//
//  Item.swift
//  Demonic Flipper
//
//  Created by David Martens on 21.09.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
