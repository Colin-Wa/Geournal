//
//  PinDetails.swift
//  Geournal
//
//  Created by Colin Anderson on 1/29/24.
//

import Foundation

import SwiftUI

import SwiftData

struct PinDescView: View {
    @Environment (\.modelContext) private var context
    
    @State var desc:PinDescription
    @State var pin:PinData
    @State var showing_alert = false
    
    @State private var empty_alert = false
    
    func editDesc() {
        if (desc.title.isEmpty || desc.description.isEmpty)
        {
            empty_alert = true
        }
        else
        {
            if let index = pin.descriptions.firstIndex(where: {$0.id == desc.id})
            {
                pin.descriptions[index].title = desc.title
                pin.descriptions[index].date = desc.date
                pin.descriptions[index].description = desc.description
                
                do {
                    try context.save()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteDescription() {
        if let index = pin.descriptions.firstIndex(where: {$0.id == desc.id})
        {
            pin.descriptions.remove(at: index)
            
            do {
                try context.save()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            Divider()
            TextField("Edit Entry Title",text: $desc.title).font(.system(size: 18)).fontWeight(.semibold)
            DatePicker("", selection: $desc.date, displayedComponents: [.date,.hourAndMinute])
            TextField("",text: $desc.description, axis: .vertical).padding([.top,.bottom],10)
            HStack {
                Button(action: editDesc) {
                    Text("Save Description")
                }.frame(maxWidth: .infinity)
                Button("Delete Description", role: .destructive)
                {
                    showing_alert = true
                }.frame(maxWidth: .infinity).alert("Are you sure you want to delete this description?", isPresented: $showing_alert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        deleteDescription()
                    }
                }
            }
        }.alert("All fields must be filled before saving pin description", isPresented: $empty_alert)
        {
            Button(action: {empty_alert = false})
            {
                Text("Ok")
            }
        }
    }
}
