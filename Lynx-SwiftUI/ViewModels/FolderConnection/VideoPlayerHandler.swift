import SwiftUI
import AVKit
import Combine

@Observable final class VideoPlayerHandler {
    var videoDone = false
    
    let player = AVPlayer(url: Bundle.main.url(forResource: "HowToUpload", withExtension: "mov")!)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { (_) in
                withAnimation {
                    self.videoDone = true
                }
            }.store(in: &cancellables)
    }
}
