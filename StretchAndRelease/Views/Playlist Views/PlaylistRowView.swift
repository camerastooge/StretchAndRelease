//
//  PlaylistRowView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import SwiftUI

struct PlaylistRowView: View {
    @Bindable var item: PlaylistItem
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 150), alignment: .leading), //name
        GridItem(.fixed(40), alignment: .center),               //stretch
        GridItem(.fixed(40), alignment: .center),               //rest
        GridItem(.fixed(40), alignment: .center)                //reps
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            Text(item.name)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .layoutPriority(1)
            
            Text("\(item.stretchDuration)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("\(item.restDuration)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("\(item.repsToComplete)")
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    
    PlaylistRowView(item: item)
}
