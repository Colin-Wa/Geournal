//
//  ContentView.swift
//  Geournal
//
//  Created by Colin Anderson on 1/19/24.
//

import SwiftUI

import MapKit

import SwiftData

struct ContentView: View {
    @State var longPressLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    @State private var isShowingSheet:Bool = false
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 30, longitude: -95), distance: 25000000))
    )
    
    @State private var current_pin: PinData? = nil
    
    @State private var show_details: Bool = false
    
    @State private var filter_sheet: Bool = false
    
    @State private var all_pins_enabled: Bool = true
    
    @State private var map_region:MKCoordinateRegion = MKCoordinateRegion()
    
    @Query var pins: [PinData]
    
    @Query var tags: [TagData]
    
    var body: some View {
        MapReader { reader in
            Map(position: $position, interactionModes: [.all])
            {
                ForEach(pins) {pin in
                    if(pin.inFrame && (all_pins_enabled || pin.tags.contains(where: {$0.enabled_in_filter == true})))
                    {
                        Annotation(pin.title, coordinate: pin.coordinates.locationCoordinate())
                        {
                            Image(systemName: "mappin.circle.fill").resizable().foregroundColor( pin.determine_color(all_pins_enabled: all_pins_enabled)).frame(width: 44, height: 44).clipShape(.circle).background(.white).clipShape(.circle).onTapGesture(perform: {
                                current_pin = pin
                            })
                        }
                    }
                }
                UserAnnotation()
            }.onMapCameraChange(frequency: .onEnd)
            { context in
                map_region = context.region
                for pin in pins {
                    pin.checkInFrame(field: map_region)
                }
            }
            .gesture(LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                .onEnded {
                    value in
                    var temp_coordinates:CGPoint
                    switch value{
                    case .second(true, let drag):
                        temp_coordinates = drag?.location ?? .zero
                        longPressLocation = reader.convert(temp_coordinates, from: .local) ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                        self.isShowingSheet = true
                    default: break
                    }
                }
            ).highPriorityGesture(DragGesture(minimumDistance: 10))
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {filter_sheet = true})
            {
                Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 30, height: 30).padding(10)
            }
        }
        .sheet(isPresented: $filter_sheet)
        {
            NavigationView {
                FilterView(all_pins: $all_pins_enabled).toolbar{
                    Button(action: {filter_sheet = false}) {
                        Text("Close")
                    }
                }
            }
        }
        .sheet(item: $current_pin, onDismiss: {
            current_pin = nil
        })
        { pin in
            PinDetails(pin: pin, sheet_toggle: $current_pin).presentationDetents([.medium,.large])
        }
        .sheet(isPresented: $isShowingSheet) {
            NavigationView {
                CreatePin(longPressLocation: self.$longPressLocation, isShowingSheet: self.$isShowingSheet).presentationDetents([.large]).toolbar {
                    Button(action: {isShowingSheet = false})
                    {
                        Text("Cancel")
                    }
                }
            }.onDisappear()
            {
                for pin in pins {
                    pin.checkInFrame(field: map_region)
                }
            }
        }.onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: [PinData.self, TagData.self])
        .modelContainer(for: [PinData.self, TagData.self])
//        .modelContainer(for: TagData.self)
}
