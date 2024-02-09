//
//  CreateNewTag.swift
//  Geournal
//
//  Created by Colin Anderson on 2/4/24.
//

import SwiftUI

struct CreateNewTag: View {
    @Environment (\.modelContext) private var context
    @Environment (\.self) var environment
    @Environment (\.presentationMode) var presentationMode: Binding
    
    @State private var tag_title: String = ""
    @State private var tag_color: Color = Color.red
    
    @State private var empty_alert:Bool = false
    
    func saveTag() {
        if (tag_title.isEmpty) {
            empty_alert = true
        }
        else
        {
            let resolved: Color.Resolved = tag_color.resolve(in: environment)
            context.insert(TagData(title: tag_title, color: color_codable(r: CGFloat(resolved.red), g: CGFloat(resolved.green),b: CGFloat(resolved.blue))))
            
            do {
                try context.save()
            }
            catch {
                print(error.localizedDescription)
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        List {
            TextField("Title", text: $tag_title)
            ColorPicker("Tag Color", selection: $tag_color, supportsOpacity: false)
            Button("Create Tag", action: saveTag)
        }.navigationTitle("Create Tag").alert("Please enter a tag title to save",isPresented: $empty_alert)
        {
            Button("Ok", action: {empty_alert = false})
        }
    }
}

#Preview {
    CreateNewTag()
}
