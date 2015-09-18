//
//  NekoScreenSaverView.swift
//  NekoScreenSaverOSX
//
//  Created by Chan Fai Chong on 18/9/2015.
//  Copyright © 2015 Ignition Soft. All rights reserved.
//

import ScreenSaver
import AVFoundation
import AVKit

class NekoScreenSaverView : ScreenSaverView {
    static let NekoVideoId = "Zi9cK-lI190"

    let screenSaverController = YouTubePlayerController(youTubeId: "Zi9cK-lI190")
    var playerView : AVPlayerView!

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 30.0
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        // build a player
        playerView = AVPlayerView()
        playerView.controlsStyle = .None
        playerView.frame = self.bounds
        playerView.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        self.addSubview(playerView)

        screenSaverController.setup()
        playerView.player = screenSaverController.player
    }
}