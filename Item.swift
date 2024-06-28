//
//  Item.swift
//  ToDos
//
//  Created by Tunde Adegoroye on 06/06/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var timestamp: Date
    var isCritical: Bool
    var isCompleted: Bool
    var elo: Int

    @Relationship(deleteRule: .nullify, inverse: \Category.items)
    var category: Category?
    
    @Attribute(.externalStorage)
    var image: Data?
    
    init(title: String = "",
         timestamp: Date = .now,
         isCritical: Bool = false,
         isCompleted: Bool = false) {
        self.title = title
        self.timestamp = timestamp
        self.isCritical = isCritical
        self.isCompleted = isCompleted
        self.elo = 1000
    }
}

extension Item {
    
    static var dummy: Item {
        .init(title: "Item 1",
              timestamp: .now,
              isCritical: true)
    }
}
