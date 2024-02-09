//
//  SelectTags.swift
//  Geournal
//
//  Created by Colin Anderson on 2/2/24.
//

import SwiftUI

import SwiftData

struct SelectTags: View {
    @Environment(\.modelContext) private var context
    
    @Binding var selected_tags: [TagData]
    
    @Query var tags: [TagData]
    
    @Query var pins: [PinData]
    
    var body: some View {
        List {
            ForEach(tags) {tag in
                Button(action: {
                    if ( !selected_tags.contains(where: {$0.id == tag.id}) )
                    {
                        selected_tags.append(tag)
                    }
                    else {
                        if let index = selected_tags.firstIndex(where: {$0.id == tag.id}){
                            selected_tags.remove(at: index)
                        }
                    }
                })
                {
                    HStack {
                        Text(tag.title)
                        Spacer()
                        if (selected_tags.contains(where: {$0.id == tag.id}))
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
            NavigationLink("Create new tag") {
                CreateNewTag()
            }
        }
    }
}

#Preview {
    @State var tags:[TagData] = [TagData]()
    return SelectTags(selected_tags: $tags)
}
