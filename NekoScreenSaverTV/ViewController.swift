//
//  ViewController.swift
//  NekoScreenSaverTV
//
//  Created by Chan Fai Chong on 18/9/2015.
//  Copyright © 2015 Ignition Soft. All rights reserved.
//

import UIKit
import AVKit

class AVView : UIView {
    init(frame: CGRect, player: AVPlayer) {
        super.init(frame: frame)

        let layer = self.layer as! AVPlayerLayer
        layer.player = player
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func layerClass() -> (AnyClass) {
        return AVPlayerLayer.self
    }
}

class ViewController: UIViewController {
    static let NekoVideoId = "Zi9cK-lI190"
    let screenSaverController = YouTubePlayerController(youTubeId: NekoVideoId)
    var avView : AVView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        super.loadView()

        screenSaverController.setup()

        avView = AVView(frame: self.view.bounds, player: screenSaverController.player)
        avView!.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.addSubview(avView!)
    }
}

