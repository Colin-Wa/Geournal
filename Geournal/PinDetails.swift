//
//  PinDetails.swift
//  Geournal
//
//  Created by Colin Anderson on 1/29/24.
//

import Foundation

import SwiftUI

import SwiftData

// Package from https://github.com/diniska/swiftui-wrapping-stack
import WrappingStack

struct PinDetails: View {
    @Environment (\.modelContext) var context
    
    @State var pin: PinData
    @Binding var sheet_toggle: PinData?
    
    @State private var showing_alert = false
    
    @State private var show_tag_menu = false
    
    func addDescription() {
        pin.descriptions.append(PinDescription(title: "New entry", date: Date(), description: "New entry description"))
        pin.descriptions.sort(by: {$0.date > $1.date})
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func deletePin() {
        context.delete(pin)
        
        do {
            try context.save()
            sheet_toggle = nil
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView() {
                VStack(alignment: .leading)
                {
                    Text(pin.title).font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).padding([.bottom],10)
                    Divider()
                    Text("Tags")
                    // Package from https://github.com/diniska/swiftui-wrapping-stack
                    WrappingHStack(alignment: .leading) {
                        ForEach(pin.tags) {tag in
                            HStack {
                                HStack {
                                    HStack {
                                        Text(tag.title)
                                        Spacer()
                                        Button(action: {
                                            if let index = pin.tags.firstIndex(where: {$0 == tag}){
                                                pin.tags.remove(at: index)
                                                
                                                do {
                                                    try context.save()
                                                }
                                                catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        })
                                        {
                                            Image(systemName: "multiply")
                                        }
                                    }.padding(8)
                                }.background(tag.color.toColor).fixedSize(horizontal: true, vertical: true).cornerRadius(8).padding(3)
                            }
                        }
                    }
                    NavigationLink("Select Tags",destination: SelectTags(selected_tags: $pin.tags))
                    Divider()
                    HStack {
                        Button(action: addDescription){
                            Text("Add new entry")
                        }.frame(maxWidth: .infinity).fontWeight(.bold)
                        Button("Delete pin", role: .destructive) {
                            showing_alert = true
                        }.fontWeight(.bold).frame(maxWidth: .infinity).alert("Are you sure you want to delete this pin?", isPresented: $showing_alert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Yes", role: .destructive) {
                                deletePin()
                            }
                        }
                    }.padding([.bottom],10)
                    ForEach(pin.descriptions, id: \.id) { desc in
                        PinDescView(desc: desc, pin: pin)
                    }
                    Spacer()
                }
            }.padding([.top,.leading, .trailing],20)
        }
    }
}
