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

public class YouTubePlayerController : NSObject {
    private var youTubeId : String
    public dynamic var player : AVPlayer
    
    public init(youTubeId: String) {
        self.youTubeId = youTubeId
        self.player = AVPlayer()
    }
    
    public func setup() {
        addObserver(self, forKeyPath: "player.status", options: .New, context: nil)

        // find video URL
        YouTubeExtractor.sharedExtractor.extractVideoForIdentifier(youTubeId) { [weak self] (videos, error) -> Void in
            if let videos = videos {
                if let video = videos.filter({$0.quality == .HD1080}).first ??
                        videos.filter({$0.quality == .HD720}).first ??
                        videos.filter({$0.quality == .Medium360}).first ??
                        videos.filter({$0.quality == .Small240}).first ??
                        videos.first {
                    print("video.videoURL: \(video.videoURL)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?.playVideoAtURL(video.videoURL)
                    })
                } else {
                    print("no videos found: \(videos)")
                }
            } else {
                print("no videos found: \(error)")
            }
        }
    }
    
    public func shutdown() {
        removeObserver(self, forKeyPath: "player.status") // can only be called once, or it will be crashed, but we have nothing to do here
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playVideoAtURL(URL: NSURL) {
        self.player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: URL))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func playerDidEnded(n: NSNotification) {
        self.player.seekToTime(kCMTimeZero)
    }
    
    func seekToRandomTimeAndPlay() {
        if let duration = self.player.currentItem?.asset.duration {
            let randomTime = Float64(arc4random() % UInt32(duration.seconds))
            self.player.seekToTime(CMTimeMakeWithSeconds(randomTime, Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            self.player.play()
        }
    }
    
    @objc public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "player.status" && self.player.status == .ReadyToPlay {
            self.seekToRandomTimeAndPlay()
        }
    }
}