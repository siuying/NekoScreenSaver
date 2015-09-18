//
//  NekoScreenSaverController.swift
//  NekoScreenSaverOSX
//
//  Created by Chan Fai Chong on 18/9/2015.
//  Copyright © 2015 Ignition Soft. All rights reserved.
//

import Foundation

import AVFoundation
import AVKit

public class YouTubeScreenSaverController : NSObject {
    public var playerView : AVPlayerView!

    private var youTubeId : String
    private dynamic var player : AVPlayer?
    
    public init(youTubeId: String) {
        self.youTubeId = youTubeId
    }
    
    public func setup() {
        // build a player
        playerView = AVPlayerView()
        playerView.controlsStyle = .None

        addObserver(self, forKeyPath: "player.status", options: .New, context: nil)

        // find video URL
        IGYouTubeExtractor.sharedInstance().extractVideoForIdentifier(youTubeId) { [weak self] (data, error) -> Void in
            if let controller = self {
                if let error = error {
                    Swift.print("error loading data: \(error)")

                } else if let video = data.first as? IGYouTubeVideo {
                    if let videoURL = video.videoURL {
                        dispatch_async(dispatch_get_main_queue()) {
                            print("URL found: \(videoURL)")
                            controller.playVideoAtURL(videoURL)
                        }
                    } else {
                        print("URL not found: \(data)")
                    }
                }
            }
        }
    }
    
    public func shutdown() {
        removeObserver(self, forKeyPath: "player.status") // can only be called once, or it will be crashed, but we have nothing to do here
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playVideoAtURL(URL: NSURL) {
        self.player = AVPlayer(URL: URL)
        self.playerView.player = player
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func playerDidEnded(n: NSNotification) {
        self.player?.seekToTime(kCMTimeZero)
    }
    
    func seekToRandomTimeAndPlay() {
        if let duration = self.player?.currentItem?.asset.duration {
            let randomTime = Float64(arc4random() % UInt32(duration.seconds))
            self.player?.seekToTime(CMTimeMakeWithSeconds(randomTime, Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            self.player?.play()
        }
    }
    
    @objc public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "player.status" && self.player?.status == .ReadyToPlay {
            self.seekToRandomTimeAndPlay()
        }
    }
}