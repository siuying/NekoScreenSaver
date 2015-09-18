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
    let screenSaverController = YouTubeScreenSaverController(youTubeId: "Zi9cK-lI190")
    
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
        screenSaverController.setup()

        // setup frame
        screenSaverController.playerView.frame = self.bounds
        screenSaverController.playerView.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        self.addSubview(screenSaverController.playerView)
    }
}