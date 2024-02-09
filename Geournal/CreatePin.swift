//
//  CreatePin.swift
//  Geournal
//
//  Created by Colin Anderson on 1/22/24.
//

import Foundation

import SwiftUI

import MapKit

import SwiftData

// Package from https://github.com/diniska/swiftui-wrapping-stack
import WrappingStack

struct CreatePin: View {
    @Binding var longPressLocation: CLLocationCoordinate2D
    @Binding var isShowingSheet: Bool
    
    @State private var pin_title:String = ""
    @State private var entry_title:String = ""
    @State private var pin_date:Date = Date.now
    @State private var pin_desc:String = ""
    @State private var pin_tags:[TagData] = [TagData]()
    
    @State private var empty_alert: Bool = false
    
    @Environment (\.modelContext) private var context
    
    func savePin() -> Void {
        if(pin_title.isEmpty || entry_title.isEmpty || pin_desc.isEmpty)
        {
            empty_alert = true
        }
        else
        {
            let pin_data = PinData(coordinates: Coordinate(latitude: longPressLocation.latitude, longitude: longPressLocation.longitude), title: pin_title, description: PinDescription(title: entry_title, date: pin_date, description: pin_desc), tags: pin_tags)
            context.insert(pin_data)
            do {
                try context.save()
            }
            catch {
                print(error.localizedDescription)
            }
            isShowingSheet = false
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Pin Details")) {
                TextField("",text: $pin_title, prompt: Text("Name of Pin"))
                NavigationLink("Select Tags",destination: SelectTags(selected_tags: $pin_tags))
                if (pin_tags != [])
                {
                    // Package from https://github.com/diniska/swiftui-wrapping-stack
                    WrappingHStack(alignment: .leading) {
                        ForEach(pin_tags) {tag in
                            HStack {
                                HStack {
                                    HStack {
                                        Text(tag.title)
                                    }.padding(8)
                                }.background(tag.color.toColor).fixedSize(horizontal: true, vertical: true).cornerRadius(8)
                            }.padding(3)
                        }
                    }
                }
            }
            Section(header: Text("Initial Entry Details")) {
                TextField("",text: $entry_title, prompt: Text("Name of Entry"))
                DatePicker("Date", selection: $pin_date).fontWeight(.semibold).font(.system(size: 18))
                ZStack(alignment: .topLeading){
                    TextEditor(text: $pin_desc).background()
                    if (pin_desc.isEmpty) {
                        Text("Enter pin description...").padding(.top, 10).allowsHitTesting(false).opacity(0.25)
                    }
                }.padding([.bottom],6)
            }
            Button(action: savePin){
                Text("Create Pin")
            }
        }.alert("All fields must be completed before creating a new pin", isPresented: $empty_alert)
        {
            Button(action: {empty_alert = false})
            {
                Text("Ok")
            }
        }
    }
}

#Preview {
    @State var loc = CLLocationCoordinate2D(latitude: 37.33779, longitude: -122.00500)
    @State var isShowing = true
    return CreatePin(longPressLocation: $loc, isShowingSheet: $isShowing)
}
