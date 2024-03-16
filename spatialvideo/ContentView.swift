//
//  ContentView.swift
//  spatialvideo
//
//  Created by BillyM2 on 3/16/24.
//

import SwiftUI
import AVKit
import PhotosUI

struct ContentView: View {
    @ObservedObject var model = SpatialModel()
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var showPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let player = model.player {
                        Text("Spatial Video")
                        VideoPlayer(player: player)
                            .frame(height: 320)
                        
                        if let leftImage = model.leftImage {
                            Text("Left Eye")
                            Image(uiImage: leftImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        if let rightImage = model.rightImage {
                            Text("Right Eye")
                            Image(uiImage: rightImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    } else {
                        Button {
                            showPicker = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .frame(height: 300)
                        Text("https://github.com/bipark/SpatialVideoSeparate-Swift")
                    }
                }
            }
            .toolbar {
                Button {
                    showPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .photosPicker(isPresented: $showPicker, selection: $selectedPhoto, matching: .any(of: [.videos]))
            .onChange(of: selectedPhoto) {
                Task { [self] in
                    let movie = try! await self.selectedPhoto?.loadTransferable(type: Movie.self)
                    await model.loadVideo(url: movie!.url)
                }
            }

            .navigationTitle("Spatial Video")
        }
        .padding()
    }
}

