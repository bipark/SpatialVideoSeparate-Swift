//
//  SpatialModel.swift
//  spatialvideo
//
//  Created by BillyM2 on 3/16/24.
//

import AVKit

class SpatialModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var leftImage: UIImage?
    @Published var rightImage: UIImage?

    var displayLink: CADisplayLink!
    var videoOutput: AVPlayerVideoOutput!
    let context = CIContext()

    func loadVideo(url:URL) async {
        
        let asset = AVAsset(url: url)
        if (try! await asset.loadTracks(withMediaCharacteristic: .containsStereoMultiviewVideo).first) != nil {
            player = AVPlayer(playerItem:AVPlayerItem(asset: asset))
            
            let outputSpecification = AVVideoOutputSpecification(
                tagCollections: [.stereoscopicForVideoOutput()]
            )
            videoOutput = AVPlayerVideoOutput(specification: outputSpecification)
            player?.videoOutput = videoOutput
            
            displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLink(link:)))
            displayLink.add(to: .main, forMode: .common)

            player?.play()
        }
    }
    
    @objc func onDisplayLink(link: CADisplayLink) {
        guard let taggedBuffers = videoOutput.taggedBuffers(forHostTime: CMClockGetTime(CMClockGetHostTimeClock())) else {
            return
        }

        let leftBuffer = taggedBuffers.taggedBufferGroup.first { $0.tags.contains(.stereoView(.leftEye)) }!
        let rightBuffer = taggedBuffers.taggedBufferGroup.first { $0.tags.contains(.stereoView(.rightEye)) }!

        guard case let .pixelBuffer(leftPixelBuffer) = leftBuffer.buffer,
              case let .pixelBuffer(rightPixelBuffer) = rightBuffer.buffer else { return }

        let leftCIImage  = CIImage(cvPixelBuffer: leftPixelBuffer)
        let rightCIImage = CIImage(cvPixelBuffer: rightPixelBuffer)

        let left = context.createCGImage(leftCIImage, from: leftCIImage.extent)
        let right = context.createCGImage(rightCIImage, from: rightCIImage.extent)
        
        leftImage = UIImage(cgImage:left!)
        rightImage = UIImage(cgImage: right!)
    }


}

