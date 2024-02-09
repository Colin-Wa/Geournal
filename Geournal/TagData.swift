//
//  TagData.swift
//  Geournal
//
//  Created by Colin Anderson on 2/2/24.
//

import Foundation

import SwiftUI

import SwiftData

struct color_codable : Codable {
    var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0
    var toColor:Color {
        return Color(red: r,green: g,blue: b)
    }
}

@Model

final class TagData: Identifiable {
    var id:UUID = UUID()
    var title: String
    var color: color_codable
    var enabled_in_filter:Bool = false
    
    init(title: String, color: color_codable)
    {
        self.title = title
        self.color = color
    }
}
