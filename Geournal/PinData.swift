//
//  PinData.swift
//  Geournal
//
//  Created by Colin Anderson on 1/22/24.
//

import Foundation

import SwiftUI

import MapKit

import SwiftData

struct PinDescription: Codable, Identifiable {
    var id:UUID = UUID()
    var title: String
    var date: Date
    var description: String
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

@Model

final class PinData: Identifiable {
    var coordinates: Coordinate
    var title: String
    var tags: [TagData]
    var descriptions: [PinDescription]
    var inFrame: Bool = false
    func determine_color(all_pins_enabled: Bool) -> Color {
        if(!tags.isEmpty)
        {
            if(all_pins_enabled)
            {
                return tags[0].color.toColor
            }
            else if let index = tags.firstIndex(where: {$0.enabled_in_filter == true})
            {
                return tags[index].color.toColor
            }
        }
        return Color.red
    }
    func checkInFrame(field: MKCoordinateRegion)
    {
        if(abs(coordinates.latitude) - abs(field.center.latitude) <= field.span.latitudeDelta && abs(coordinates.longitude) - abs(field.center.longitude) <= field.span.longitudeDelta)
        {
            inFrame = true
        }
        else
        {
            inFrame = false
        }
    }
    
    init(coordinates: Coordinate, title: String, description: PinDescription, tags: [TagData])
    {
        self.coordinates = coordinates
        self.title = title
        self.tags = [TagData]()
        self.descriptions = []
        self.descriptions.append(description)
        for tag in tags
        {
            self.tags.append(tag)
        }
    }
}
