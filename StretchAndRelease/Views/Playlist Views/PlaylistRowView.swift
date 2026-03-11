//
//  PlaylistRowView.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 2/26/26.
//

import SwiftUI

struct PlaylistRowView: View {
    @Bindable var item: PlaylistItem
    let columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text(item.name)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)
                .layoutPriority(1)
                .padding(.leading, 5)
            
            Text("\(item.stretchDuration)")
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(item.restDuration)")
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(item.repsToComplete)")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var item = PlaylistItem.sampleData[0]
    let playlistColumns: [GridItem] = [
        GridItem(.flexible(minimum: 150), alignment: .leading), //name
        GridItem(.fixed(40), alignment: .center),               //stretch
        GridItem(.fixed(40), alignment: .center),               //rest
        GridItem(.fixed(40), alignment: .center),                //reps
    ]
    PlaylistRowView(item: item, columns: playlistColumns)
}
