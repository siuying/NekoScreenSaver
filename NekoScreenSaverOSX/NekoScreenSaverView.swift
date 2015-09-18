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

    var kvoController : FBKVOController!
    var playerView : AVPlayerView!
    dynamic var player : AVPlayer?

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
        playerView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        playerView.frame = self.bounds
        playerView.controlsStyle = .None
        self.addSubview(playerView)
        
        // when status is READY, start play
        kvoController = FBKVOController(observer: self)
        kvoController.observe(self, keyPath: "player.status", options: .New, action: "playerStatusChanged")

        // find video URL
        IGYouTubeExtractor.sharedInstance().extractVideoForIdentifier(NekoScreenSaverView.NekoVideoId) { (data, error) -> Void in
            if let error = error {
                Swift.print("error loading data: \(error)")
            } else if let video = data.first as? IGYouTubeVideo {
                if let videoURL = video.videoURL {
                    dispatch_async(dispatch_get_main_queue()) {
                        Swift.print("URL found: \(videoURL)")
                        self.playVideoAtURL(videoURL)
                    }
                } else {
                    Swift.print("URL not found: \(data)")
                }
            }
        }
    }

    func playerStatusChanged() {
        if let player = self.player {
            if player.status == .ReadyToPlay {
                self.seekToRandomTimeAndPlay()
            }
        }
    }
    
    func playVideoAtURL(URL: NSURL) {
        self.player = AVPlayer(URL: URL)
        self.player!.muted = self.preview
        self.playerView.player = player
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func playerDidEnded(n: NSNotification) {
        self.player?.seekToTime(kCMTimeZero)
    }
    
    func seekToRandomTimeAndPlay() {
        let randomTime = Float64(arc4random() % 40235)
        self.player?.seekToTime(CMTimeMakeWithSeconds(randomTime, Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.player?.play()
    }
}