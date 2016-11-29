//
//  VideoTable.swift
//  ToothSense
//
//  Created by Dillon Murphy on 8/25/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import UIKit
import Foundation
import AVKit
import AVFoundation



class VideoTable: UITableViewController, NavgationTransitionable {
    
    @IBOutlet var VideoTableTabAnimation: RAMFumeAnimation!
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Videos"
        view.backgroundColor = AppConfiguration.backgroundColor
        tableView.backgroundColor = AppConfiguration.backgroundColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateOrientationAnimated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        removeBack()
        addHamMenu()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sideMenuNavigationController = self.navigationController!
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        if playingVideo != nil {
            playingVideo!.playerController.player!.pause()
        }
        UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.Portrait.rawValue), forKey: "orientation")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - <UITableViewDataSource>
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? VideoCell else { return }
        cell.setupResource(self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return screenBounds.width * (8/15)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let topView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: 5))
        topView.backgroundColor = AppConfiguration.backgroundColor
        return topView
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let bottomView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: 5))
        bottomView.backgroundColor = AppConfiguration.backgroundColor
        return bottomView
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func updateOrientationAnimated(animated: Bool) {
        if (UIDevice.currentDevice().orientation == previousOrientation) {
            return
        }
        if playingVideo != nil {
            switch (UIDevice.currentDevice().orientation) {
            case UIDeviceOrientation.LandscapeRight:
                playingVideo!.playerController.view.cheetah.duration(0.1).rotate(-M_PI_2).scale(1.8).run()
                playingVideo!.PlayButton.cheetah.duration(0.1).rotate(-M_PI_2).run()
                playingVideo!.miniButton.cheetah.duration(0.1).rotate(-M_PI_2).run()
            case UIDeviceOrientation.LandscapeLeft:
                playingVideo!.playerController.view.cheetah.duration(0.1).rotate(M_PI_2).scale(1.8).run()
                playingVideo!.PlayButton.cheetah.duration(0.1).rotate(M_PI_2).run()
                playingVideo!.miniButton.cheetah.duration(0.1).rotate(M_PI_2).run()
            case UIDeviceOrientation.FaceDown: return
            case UIDeviceOrientation.FaceUp: return
            case UIDeviceOrientation.Unknown: return
            default:
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    playingVideo!.playerController.view.transform = CGAffineTransformIdentity
                    playingVideo!.PlayButton.transform = CGAffineTransformIdentity
                    playingVideo!.miniButton.transform = CGAffineTransformIdentity
                }, completion: nil)
            }
            previousOrientation = UIDevice.currentDevice().orientation
        }
    }
    
}



var playingVideo: VideoCell?
var playimage: UIImage = Images.resizeImage(UIImage(named: "playImage")!, width: (screenBounds.width) / 2, height: (screenBounds.width * (8/15)) / 2)!.imageMaskedWithColor(UIColor.whiteColor())


extension UIView {
    func removeLoaderView() {
        for sub in self.subviews {
            if sub is UIActivityIndicatorView {
                sub.removeFromSuperview()
            } else {
                sub.removeLoaderView()
            }
        }
    }
}

// MARK: - types

public enum PlaybackState: Int, CustomStringConvertible {
    case Stopped = 0
    case Playing
    case Paused
    case Failed
    
    public var description: String {
        get {
            switch self {
            case Stopped:
                return "Stopped"
            case Playing:
                return "Playing"
            case Failed:
                return "Failed"
            case Paused:
                return "Paused"
            }
        }
    }
}


public enum BufferingState: Int, CustomStringConvertible {
    case Unknown = 0
    case Ready
    case Delayed
    
    public var description: String {
        get {
            switch self {
            case Unknown:
                return "Unknown"
            case Ready:
                return "Ready"
            case Delayed:
                return "Delayed"
            }
        }
    }
}

extension UIResponder {
    func delay(seconds: Double, task: () -> Void) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
        dispatch_after(time, dispatch_get_main_queue(), task)
    }
}

public class VideoCell: UITableViewCell {
    
    let width = screenBounds.width
    let height = screenBounds.width * (8/15)
    
    func animateCellWithTransform() {
        let duration: NSTimeInterval = 0.3
        let damping: CGFloat = 0.55
        let degrees = CGFloat(sin(90.0 * M_PI/180.0))
        self.layer.setAffineTransform(CGAffineTransformMakeRotation(degrees))//CGAffineTransformMakeScale(-1,-1))
        UIView.animateWithDuration(duration, delay: self.delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
            self.visualEffectView.frame = self.visualEffectView.frame.offsetBy(dx: self.width, dy: 0)
            self.layer.setAffineTransform(CGAffineTransformIdentity)
            self.placeHolderImage.alpha = 1.0
            }, completion: { finished in
                self.PlayButton.cheetah.alpha(0.9).duration(0.3).run()
                self.playerController.view.alpha = 1.0
                self.miniButton.alpha = 0.9
        })
    }
    
    @IBInspectable var videoName: String!
    @IBInspectable var videoExt: String! {
        didSet {
            if let path = NSBundle.mainBundle().pathForResource(self.videoName, ofType: self.videoExt) {
                self.resource = NSURL(fileURLWithPath: path)
                self.playerItem = AVPlayerItem.init(URL: self.resource)
                self.player = AVPlayer(playerItem: self.playerItem)
            }
        }
    }
    
    var playbackState: PlaybackState = .Stopped
    
    public var bufferingState: BufferingState = .Unknown
    
    public var bufferSize: Double = 10
    
    public var currentTime: NSTimeInterval {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.currentTime())
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    var controller: VideoTable!
    var playerController:AVPlayerViewController = AVPlayerViewController()
    
    // MARK: - private instance vars
    
    private var asset: AVAsset!
    internal var playerItem: AVPlayerItem?
    internal var player: AVPlayer {
        get {
            return self.playerController.player!
        }
        set {
            self.playerController.player = newValue
        }
    }
    
    var PlayButton: UIButton = UIButton(type: UIButtonType.Custom)
    var miniButton: UIButton = UIButton(type: UIButtonType.Custom)
    var resetButton: UIButton = UIButton(type: UIButtonType.Custom)
    
    var visualEffectView: VisualEffectView!
    
    var loaded: Bool = false
    
    var resource: NSURL!
    
    var placeHolderImage: UIImageView = UIImageView()
    
    var delay: NSTimeInterval = 1
    
    func setupImageView() {
        switch self.videoName {
        case "toby": self.placeHolderImage.image = UIImage(named: "SugarBugScreenShot")!
        self.delay = 0.0
        case "babyteeth": self.placeHolderImage.image = UIImage(named: "babyteethScreenShot")!
        self.delay = 0.3
        case "babypart1": self.placeHolderImage.image = UIImage(named: "part1ScreenShot")!
        self.delay = 0.6
        case "babypart2": self.placeHolderImage.image = UIImage(named: "part2ScreenShot")!
        self.delay = 0.3
        case "babypart3": self.placeHolderImage.image = UIImage(named: "part3ScreenShot")!
        self.delay = 0.3
        case "teething": self.placeHolderImage.image = UIImage(named:"teethingScreenShot")!
        self.delay = 0.3
        default: self.placeHolderImage.image = nil
        self.delay = 0
        }
    }
    
    func setupResource(viewController: VideoTable) {
        if !self.loaded {
            controller = viewController
            visualEffectView = VisualEffectView(frame: CGRect(x: -width, y: 0, width: width, height: height))
            visualEffectView.colorTint = AppConfiguration.backgroundColor.lightenedColor(0.2)
            visualEffectView.colorTintAlpha = 0.9
            visualEffectView.blurRadius = 10
            visualEffectView.scale = 1
            contentView.addSubview(visualEffectView)
            
            if videoName != nil && videoExt != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.itemDidFinishPlaying), name:AVPlayerItemDidPlayToEndTimeNotification, object:self.playerItem)
                backgroundColor = AppConfiguration.navColor
                playerController.view.frame = CGRect(x: 2.5, y: 2.5, width: width - 5, height: height - 5)
                playerController.view.backgroundColor = .clearColor()
                playerController.view.alpha = 0.0
                playerController.showsPlaybackControls = false
                controller.addChildViewController(playerController)
                visualEffectView.addSubview(playerController.view)
            }
            
            self.placeHolderImage.contentMode = .ScaleAspectFit
            self.placeHolderImage.backgroundColor = UIColor.clearColor()
            self.placeHolderImage.frame = CGRect(x: 2.5, y: 2.5, width: width - 5, height: height - 5)
            self.placeHolderImage.alpha = 0
            self.visualEffectView.addSubview(self.placeHolderImage)
            
            PlayButton.setImage(playimage, forState: .Normal)
            PlayButton.frame = playerController.view.frame
            PlayButton.backgroundColor = UIColor.clearColor()
            PlayButton.addTarget(self, action: #selector(self.tappedPlay), forControlEvents: .TouchUpInside)
            visualEffectView.addSubview(PlayButton)
            PlayButton.alpha = 0
            resetButton.setImage(UIImage(named: "BeginningButton")!, forState: .Normal)
            resetButton.frame = CGRect(x: 30, y: height - 60, width: 50, height: 50)
            resetButton.backgroundColor = UIColor.clearColor()
            resetButton.tintColor = UIColor.whiteColor()
            resetButton.addTarget(self, action: #selector(self.resetVideo), forControlEvents: .TouchUpInside)
            visualEffectView.addSubview(resetButton)
            resetButton.alpha = 0
            resetButton.enabled = false
            
            self.loaded = true
            self.setupImageView()
            
            miniButton.setImage(UIImage(named: "minimize")!, forState: .Normal)
            miniButton.frame = CGRect(x: screenBounds.width, y: 10, width: 50, height: 50)
            miniButton.backgroundColor = UIColor.clearColor()
            miniButton.tintColor = UIColor.whiteColor()
            miniButton.addTarget(self, action: #selector(self.tappedMini), forControlEvents: .TouchUpInside)
            miniButton.alpha = 0.0
            visualEffectView.addSubview(miniButton)
            contentView.removeLoaderView()
            
            self.animateCellWithTransform()
        }
    }
    
    // MARK: - functions
    
    public func resetVideo() {
        self.resetButton.cheetah.alpha(0.0).duration(0.2).run().completion {
            self.resetButton.enabled = false
            self.placeHolderImage.hidden = false
        }
        self.player.seekToTime(kCMTimeZero)
    }
    
    public func playFromBeginning() {
        self.player.seekToTime(kCMTimeZero)
        self.playFromCurrentTime()
    }
    
    public func playFromCurrentTime() {
        self.playbackState = .Playing
        self.player.play()
    }
    
    public func pause() {
        if self.playbackState != .Playing {
            return
        }
        self.player.pause()
        self.playbackState = .Paused
    }
    
    public func stop() {
        if self.playbackState == .Stopped {
            return
        }
        self.player.pause()
        self.playbackState = .Stopped
        self.resetButton.cheetah.alpha(0.9).duration(0.5).run().completion {
            self.resetButton.enabled = true
        }
    }
    
    public func seekToTime(time: CMTime) {
        if let playerItem = self.playerItem {
            return playerItem.seekToTime(time)
        }
    }
    
    func itemDidFinishPlaying(notification: NSNotification) {
        stop()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        if self.playbackState == .Playing {
            self.pause()
        }
    }
    
    public func tappedMini() {
        playingVideo = nil
        self.pause()
        PlayButton.cheetah.alpha(0.9).duration(0.2).run()
        if currentTime != 0.0 {
            resetButton.cheetah.alpha(0.9).duration(0.2).run().completion({
                self.resetButton.enabled = true
            })
        }
        self.visualEffectView.cheetah.frame(self.controller.view.convertRect(self.contentView.frame, fromView: self.contentView)).duration(0.4).easeInOutBounce.completion({
            self.contentView.addSubview(self.visualEffectView)
            self.visualEffectView.frame = self.contentView.frame
            self.playerController.view.transform = CGAffineTransformIdentity
            self.PlayButton.transform = CGAffineTransformIdentity
            self.miniButton.cheetah.move(60,0).duration(0.6).easeInOutBounce.run()
            sideMenuNavigationController!.setNavigationBarHidden(false, animated: true)
            tabController!.setTabBarVisible(true, animated: true)
        }).run()
    }
    
    public func tappedPlay() {
        if self.playbackState != .Playing {
            playingVideo = self
            guard let mainWindow: UIWindow = UIApplication.sharedApplication().delegate?.window! else {
                return
            }
            UIView.animateWithDuration(0.0, animations: {
                mainWindow.addSubview(self.visualEffectView)
                self.visualEffectView.frame = mainWindow.convertRect(self.visualEffectView.frame, fromView: self.contentView)
                }, completion: {_ in
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.visualEffectView.frame = CGRect(x: 0, y: mainWindow.frame.midY - (self.height/2), width: self.width, height: self.height)
                    }, completion: {_ in
                        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.visualEffectView.frame = mainWindow.frame
                            self.PlayButton.alpha = 0.0
                            self.resetButton.alpha = 0.0
                            self.placeHolderImage.hidden = true
                            }, completion: {_ in
                                self.playFromCurrentTime()
                                self.miniButton.frame = self.miniButton.frame.offsetBy(dx: -60, dy: 0)
                                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                                tabController!.setTabBarVisible(false, animated: true)
                        })
                })
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - KVO

// KVO contexts

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

// KVO player keys

private let PlayerTracksKey = "tracks"
private let PlayerPlayableKey = "playable"
private let PlayerDurationKey = "duration"
private let PlayerRateKey = "rate"

// KVO player item keys

private let PlayerStatusKey = "status"
private let PlayerEmptyBufferKey = "playbackBufferEmpty"
private let PlayerKeepUpKey = "playbackLikelyToKeepUp"
private let PlayerLoadedTimeRangesKey = "loadedTimeRanges"

extension VideoCell {
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch (keyPath, context) {
        case (.Some(PlayerRateKey), &PlayerObserverContext):
            true
        case (.Some(PlayerStatusKey), &PlayerItemObserverContext):
            true
        case (.Some(PlayerKeepUpKey), &PlayerItemObserverContext):
            if let item = self.playerItem {
                self.bufferingState = .Ready
                if item.playbackLikelyToKeepUp && self.playbackState == .Playing {
                    self.playFromCurrentTime()
                }
            }
            let status = (change?[NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.playerController.player = self.player
            case AVPlayerStatus.Failed.rawValue:
                self.playbackState = PlaybackState.Failed
            default:
                true
            }
        case (.Some(PlayerEmptyBufferKey), &PlayerItemObserverContext):
            if let item = self.playerItem {
                if item.playbackBufferEmpty {
                    self.bufferingState = .Delayed
                }
            }
            let status = (change?[NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.playerController.player = self.player
            case AVPlayerStatus.Failed.rawValue:
                self.playbackState = PlaybackState.Failed
            default:
                true
            }
        case (.Some(PlayerLoadedTimeRangesKey), &PlayerItemObserverContext):
            guard let item = self.playerItem else {
                return
            }
            if self.playbackState != .Playing {
                return
            }
            self.bufferingState = .Ready
            let timerange = (change?[NSKeyValueChangeNewKey] as! NSArray)[0].CMTimeRangeValue
            let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration))
            let currentTime = CMTimeGetSeconds(item.currentTime())
            if bufferedTime - currentTime >= self.bufferSize {
                self.playFromCurrentTime()
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
