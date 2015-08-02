//
//  ViewController.swift
//  SmickStudio
//
//  Created by Omar Qazi on 8/1/15.
//  Copyright (c) 2015 Omar Qazi. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class ViewController: NSViewController {
    @IBOutlet weak var videoView: AVPlayerView?
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    override func viewDidAppear() {
        if !loaded {
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.liveWindow = self.view.window?.windowController() as! NSWindowController
            
            view.window?.level = kCGMaximumWindowLevelKey
            let boundsRect = self.videoView?.bounds
            self.view.window!.aspectRatio = self.videoView!.bounds.size
            videoView?.showsFullScreenToggleButton = true
            let smickTVURL = NSURL(string: "http://broadcast.smick.tv/channel/live.m3u8")
            let player = AVPlayer(URL: smickTVURL)
            videoView?.player = player
            player.play()
            loaded = true
        }
    }


}

