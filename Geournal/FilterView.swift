//
//  FilterView.swift
//  Geournal
//
//  Created by Colin Anderson on 2/7/24.
//

import SwiftUI

import SwiftData

struct FilterView: View {
    @Query var tags: [TagData]
    @Query var pins: [PinData]
    
    @Environment(\.modelContext) var context
    
    @Binding var all_pins: Bool
    
    var body: some View {
        List {
            if tags.isEmpty {
                Text("There are no tags to filter by yet. Add a tag when editing or creating a pin.")
            }
            else {
                Button(action: {
                    all_pins = !all_pins
                    if all_pins
                    {
                        for tag in tags {
                            tag.enabled_in_filter = false
                        }
                    }
                })
                {
                    HStack {
                        Text("Enable all pins")
                        Spacer()
                        if (all_pins)
                        {
                            Image(systemName: "checkmark")
                        }
                    }.tint(Color.primary)
                }
                ForEach(tags) {tag in
                    Button(action: {
                        tag.enabled_in_filter = !tag.enabled_in_filter
                        all_pins = false
                    })
                    {
                        HStack {
                            Text(tag.title)
                            Spacer()
                            if (tag.enabled_in_filter)
                            {
                                Image(systemName: "checkmark")
                            }
                        }.tint(Color.primary)
                    }.listRowBackground(tag.color.toColor.opacity(50)).swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive, action: {
                            for pin in pins {
                                pin.tags.removeAll(where: {$0.id == tag.id})
                            }
                            context.delete(tag)
                            do {
                                try context.save()
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }) {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @State var ft = [TagData]()
    @State var ap = true
    return FilterView(all_pins: $ap)
}
