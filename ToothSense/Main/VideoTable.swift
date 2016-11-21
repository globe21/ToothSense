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


extension UIImageView {
    func generateThumbImage(url: NSURL, time: CMTime, view: UIView) {
        let asset = AVAsset(URL: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        //var time = asset.duration
        //time.value = time.value < 2 ? time.value : 2
        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: time)]) { (_, image, _, result, error) in
            if error == nil && image != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.image = UIImage(CGImage: image!)
                    /*self.contentMode = .ScaleAspectFit
                     self.backgroundColor = UIColor.clearColor()
                     self.frame = CGRect(x: 2.5, y: 2.5, width: view.frame.width - 5, height: (view.frame.width * (8/15)) - 5)
                     view.addSubview(self)*/
                    //self.setNeedsDisplay()
                }
            }
        }
    }
}

class VideoTable: UIViewController, UITableViewDataSource, UITableViewDelegate, NavgationTransitionable {
    
    
    
    @IBOutlet var VideoTableTabAnimation: RAMFumeAnimation!
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    var mediaNames: [String] = ["toby","babyteeth","babypart1","babypart2","babypart3"]// ["TeethingFinal",
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Videos"
        view.backgroundColor = AppConfiguration.backgroundColor
        tableView.backgroundColor = AppConfiguration.backgroundColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateOrientationAnimated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        tableView.registerClass(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            self.view.frame = CGRect(x: 0, y: 44, width: 414, height: 643)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            self.view.frame = CGRect(x: 0, y: 44, width: 375, height: 574)
        } else {
            self.view.frame = CGRect(x: 0, y: 44, width: 320, height: 475)
        }
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
        //self.navigationController!.tr_popToRootViewController()
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
    
    
    /*func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
     guard let cell: VideoCell = cell as? VideoCell else {
     return
     }
     if cell.loaded == false {
     cell.setupImageView()//setupResource(indexPath)
     }
     }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let resource = mediaNames[indexPath.row]
        //let cell: VideoCell = VideoCell(style: UITableViewCellStyle.Default, reuseIdentifier: "VideoCell")
        let cell: VideoCell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        cell.viewController = self
        cell.placeHolderImage.image = nil
        guard let path: String = NSBundle.mainBundle().pathForResource(resource, ofType:"mp4") else {
            guard let path2: String = NSBundle.mainBundle().pathForResource(resource, ofType:"mov") else {
                return cell
            }
            cell.resource = NSURL.init(fileURLWithPath: path2)
            cell.resourceName = resource
            cell.setupResource()
            return cell
        }
        cell.resource = NSURL.init(fileURLWithPath: path)
        cell.resourceName = resource
        cell.setupResource()
        //cell.delegate = cell//self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.width * (8/15)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaNames.count
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


extension VideoTable : CellVideoDelegate {
    
    func playerReady(cell: VideoCell) {
        
    }
    
    func playerPlaybackStateDidChange(cell: VideoCell) {
        
    }
    
    func playerBufferingStateDidChange(cell: VideoCell) {
        
    }
    
    func playerCurrentTimeDidChange(cell: VideoCell) {
        
    }
    
    func videoMinimized(cell: VideoCell) {
        //ProgressHUD.showSuccess("Minimized")
    }
    
    func videoMaximized(cell: VideoCell) {
        //playingVideo!
    }
    
    func playbackWillStartFromBeginning(player: VideoCell) {
        
    }
    
    func playbackDidEnd(player: VideoCell) {
        
    }
}



var playingVideo: VideoCell?
var playimage: UIImage = Images.resizeImage(UIImage(named: "playImage")!, width: (screenBounds.width) / 2, height: (screenBounds.width * (8/15)) / 2)!


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

// MARK: - Cell Video Delegate

@objc protocol CellVideoDelegate: class {
    optional func videoMinimized(cell: VideoCell)
    optional func videoMaximized(cell: VideoCell)
    
    func playerReady(cell: VideoCell)
    func playbackWillStartFromBeginning(cell: VideoCell)
    func playbackDidEnd(cell: VideoCell)
    func playerPlaybackStateDidChange(cell: VideoCell)
    func playerBufferingStateDidChange(cell: VideoCell)
    func playerCurrentTimeDidChange(cell: VideoCell)
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

extension VideoCell : CellVideoDelegate {
    
    
    func playerReady(cell: VideoCell) {
    }
    
    func playerPlaybackStateDidChange(cell: VideoCell) {
        
    }
    
    func playerBufferingStateDidChange(cell: VideoCell) {
        
    }
    
    func playerCurrentTimeDidChange(cell: VideoCell) {
        
    }
    
    func videoMinimized(cell: VideoCell) {
        //ProgressHUD.showSuccess("Minimized")
    }
    
    func videoMaximized(cell: VideoCell) {
        //playingVideo!
    }
    
    func playbackWillStartFromBeginning(player: VideoCell) {
        
    }
    
    func playbackDidEnd(player: VideoCell) {
        
    }
}


// perform task after given delay (in seconds)
func delay(seconds: Double, task: () -> Void) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    dispatch_after(time, dispatch_get_main_queue(), task)
}


public class VideoCell: UITableViewCell {
    
    var playbackState: PlaybackState = .Stopped {
        didSet {
            if playbackState != oldValue || !playbackEdgeTriggered {
                self.delegate?.playerPlaybackStateDidChange(self)
            }
        }
    }
    
    
    public var bufferingState: BufferingState = .Unknown {
        didSet {
            if bufferingState != oldValue || !playbackEdgeTriggered {
                self.delegate?.playerBufferingStateDidChange(self)
            }
        }
    }
    
    public var bufferSize: Double = 10
    public var playbackEdgeTriggered: Bool = true
    
    public var maximumDuration: NSTimeInterval {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.duration)
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    public var currentTime: NSTimeInterval {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.currentTime())
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    public var naturalSize: CGSize {
        get {
            if let playerItem = self.playerItem {
                let track = playerItem.asset.tracksWithMediaType(AVMediaTypeVideo)[0]
                return track.naturalSize
            } else {
                return CGSizeZero
            }
        }
    }
    
    
    var progressView: NPProgressLabel!
    let imageColor = UIColor(patternImage: UIImage(named: "Tooth")!)
    var controller: UIViewController!
    var delegate : CellVideoDelegate?
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
    
    internal var timeObserver: AnyObject!
    
    var PlayButton: UIButton = UIButton(type: UIButtonType.Custom)
    var miniButton: UIButton = UIButton(type: UIButtonType.Custom)
    var resetButton: UIButton = UIButton(type: UIButtonType.Custom)
    
    var visualEffectView: VisualEffectView!
    
    var videoConstraint: ConstraintGroup!
    
    var userVideoFile: PFFile!
    
    var loaded: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "VideoCell")
        contentView.backgroundColor = AppConfiguration.backgroundColor
        delegate = self
    }
    
    var resource: NSURL!
    var viewController: UIViewController!
    
    var resourceName: String = ""
    
    var placeHolderImage: UIImageView = UIImageView()
    
    
    func setupImageView() {
        //var time : CMTime = CMTime(seconds: 1.0, preferredTimescale: 1)
        switch self.resourceName {
        case "toby": self.placeHolderImage.image = UIImage(named: "SugarBugScreenShot")!//time = CMTime(seconds: 1.5, preferredTimescale: 10)
        case "babyteeth": self.placeHolderImage.image = UIImage(named: "babyteethScreenShot")!//time = CMTime(seconds: 1.5, preferredTimescale: 10)
        case "babypart1": self.placeHolderImage.image = UIImage(named: "part1ScreenShot")!//time = CMTime(seconds: 1.81, preferredTimescale: 100)
        case "babypart2": self.placeHolderImage.image = UIImage(named: "part2ScreenShot")!//time = CMTime(seconds: 4.0, preferredTimescale: 100)
        case "babypart3": self.placeHolderImage.image = UIImage(named: "part3ScreenShot")!//time = CMTime(seconds: 0.0, preferredTimescale: 10)
        default: self.placeHolderImage.image = UIImage(named: "part3ScreenShot")!//time = CMTime(seconds: 0.0, preferredTimescale: 1)
        }
        //self.placeHolderImage.generateThumbImage(self.resource, time: time, view: self.visualEffectView)
    }
    
    func setupResource() {
        let width = screenBounds.width
        controller = viewController
        visualEffectView = VisualEffectView(frame: CGRect(x: 0, y: 0, width: width, height: width * (8/15)))
        visualEffectView.colorTint = AppConfiguration.backgroundColor.lightenedColor(0.2)
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        contentView.addSubview(visualEffectView)
        
        progressView = NPProgressLabel(frame: CGRect(x: 0, y: visualEffectView.frame.midY - 40, width: width, height: 80))
        progressView.text = "Loading"
        progressView.fontName = "AmericanTypewriter"
        progressView.fontSize = 60
        progressView.lineWidth = 2
        progressView.setProgress(0.0, animated: true)
        let colors = [UIColor(red: 0.952941179275513, green: 0.686274528503418, blue: 0.133333340287209, alpha: 1.0), UIColor.peachColor()]
        let locations: [CGFloat] = [0.0, 1.0]
        let gradientImage = UIImage.gradientImage(colors: colors, locations: locations, size: progressView.bounds.size)
        progressView.textColor = UIColor(patternImage: gradientImage)
        let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
        moveRight.fromValue = -width
        moveRight.toValue = 0
        moveRight.duration = moveRight.settlingDuration
        moveRight.fillMode = kCAFillModeBackwards
        progressView.layer.addAnimation(moveRight, forKey: nil)
        moveRight.beginTime = CACurrentMediaTime() + 0.2
        contentView.layer.addAnimation(moveRight, forKey: nil)
        
        self.playerItem = AVPlayerItem.init(URL: self.resource)
        self.player = AVPlayer(playerItem: self.playerItem!)
        self.playerController.addObserver(self, forKeyPath: PlayerReadyForDisplayKey, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerLayerObserverContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.itemDidFinishPlaying), name:AVPlayerItemDidPlayToEndTimeNotification, object:self.playerItem)
        backgroundColor = AppConfiguration.navColor
        playerController.view.frame = CGRect(x: 2.5, y: 2.5, width: visualEffectView.frame.width - 5, height: (visualEffectView.frame.width * (8/15)) - 5)
        playerController.view.backgroundColor = .clearColor()
        playerController.showsPlaybackControls = false
        controller.addChildViewController(playerController)
        visualEffectView.addSubview(playerController.view)
        
        self.progressView.setProgress(1.0, animated: true)
        
        self.placeHolderImage.contentMode = .ScaleAspectFit
        self.placeHolderImage.backgroundColor = UIColor.clearColor()
        self.placeHolderImage.frame = CGRect(x: 2.5, y: 2.5, width: visualEffectView.frame.width - 5, height: (visualEffectView.frame.width * (8/15)) - 5)
        self.visualEffectView.addSubview(self.placeHolderImage)
        
        self.progressView.cheetah.scale(1.3).duration(1.0).wait().move(screenBounds.width, 0).duration(0.5).run().completion({
            self.progressView.removeFromSuperview()
            self.playerController.view.cheetah.alpha(1.0).duration(0.3).run()
            self.PlayButton.cheetah.alpha(0.9).duration(0.5).delay(0.4).run()
            self.loaded = true
            self.setupImageView()
            //, time: CMTime)
        })
        
        
        /*self.placeHolderImage.frame = CGRect(x: 2.5, y: 2.5, width: visualEffectView.frame.width - 5, height: (visualEffectView.frame.width * (8/15)) - 5)
         self.placeHolderImage.contentMode = .ScaleAspectFit
         self.placeHolderImage.backgroundColor = UIColor.clearColor()
         self.visualEffectView.addSubview(self.placeHolderImage)*/
        
        PlayButton.setImage(playimage, forState: .Normal)
        PlayButton.frame = playerController.view.frame
        PlayButton.backgroundColor = UIColor.clearColor()
        PlayButton.addTarget(self, action: #selector(self.tappedPlay), forControlEvents: .TouchUpInside)
        visualEffectView.addSubview(PlayButton)
        PlayButton.alpha = 0
        resetButton.setImage(UIImage(named: "BeginningButton")!, forState: .Normal)
        resetButton.frame = CGRect(x: width - 60, y: (width * (8/15)) - 60, width: 50, height: 50)
        resetButton.backgroundColor = UIColor.clearColor()
        resetButton.tintColor = UIColor.whiteColor()
        resetButton.addTarget(self, action: #selector(self.resetVideo), forControlEvents: .TouchUpInside)
        visualEffectView.addSubview(resetButton)
        resetButton.alpha = 0
        resetButton.enabled = false
        constrain(resetButton, visualEffectView) { view1, view2 in
            view1.width   == 50
            view1.height  == 50
            view1.left   == view2.left + 30
            view1.bottom  == view2.bottom - 10
        }
        
        visualEffectView.addSubview(progressView)
        
        miniButton.setImage(UIImage(named: "minimize")!, forState: .Normal)
        miniButton.frame = CGRect(x: screenBounds.width, y: 10, width: 50, height: 50)
        miniButton.backgroundColor = UIColor.clearColor()
        miniButton.tintColor = UIColor.whiteColor()
        miniButton.addTarget(self, action: #selector(self.tappedMini), forControlEvents: .TouchUpInside)
        visualEffectView.addSubview(miniButton)
        contentView.removeLoaderView()
        
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
        if self.delegate != nil {
            self.delegate?.playbackWillStartFromBeginning(self)
        }
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
        if self.delegate != nil {
            self.delegate?.playbackDidEnd(self)
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
        self.playerController.removeObserver(self, forKeyPath: PlayerReadyForDisplayKey, context: &PlayerLayerObserverContext)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        if self.playbackState == .Playing {
            self.pause()
        }
    }
    
    public func tappedMini() {
        if self.delegate != nil {
            if self.delegate!.videoMinimized != nil {
                self.delegate!.videoMinimized!(self)
            }
        }
        if playingVideo != nil {
            playingVideo = nil
        }
        self.pause()
        PlayButton.cheetah.alpha(0.9).duration(0.2).run()
        if currentTime != 0.0 {
            resetButton.cheetah.alpha(0.9).duration(0.2).run().completion({
                self.resetButton.enabled = true
            })
        }
        self.visualEffectView.cheetah.frame(self.controller.view.convertRect(self.contentView.frame, fromView: self.contentView)).duration(0.6).easeInOutBounce.completion({
            self.contentView.addSubview(self.visualEffectView)
            self.visualEffectView.frame = self.contentView.frame
            self.playerController.view.transform = CGAffineTransformIdentity
            self.PlayButton.transform = CGAffineTransformIdentity
        }).run()
        self.miniButton.cheetah.move(60,0).duration(0.6).easeInOutBounce.run()
        sideMenuNavigationController!.setNavigationBarHidden(false, animated: true)
        /*switch tabController!.selectedIndex {
        case 0:
            sideMenuNavigationController!.setNavigationBarHidden(false, animated: true)
        case 1:
            sideMenuNavigationController2!.setNavigationBarHidden(false, animated: true)
        case 2:
            sideMenuNavigationController3!.setNavigationBarHidden(false, animated: true)
        default:
            break
        }*/
        tabController!.setTabBarVisible(true, animated: true)
    }
    
    public func tappedPlay() {
        self.placeHolderImage.hidden = true
        if self.playbackState != .Playing {
            if playingVideo != nil && playingVideo != self {
                playingVideo!.pause()
                playingVideo!.PlayButton.cheetah.alpha(0.9).duration(0.2).run()
                playingVideo = self
            } else {
                playingVideo = self
            }
            self.controller.view.addSubview(self.visualEffectView)
            self.visualEffectView.frame = self.controller.view.convertRect(self.contentView.frame, fromView: self.contentView)
            UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.visualEffectView.frame = screenBounds
                self.miniButton.frame = self.miniButton.frame.offsetBy(dx: -60, dy: 0)
                sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                /*switch tabController!.selectedIndex {
                case 0:
                    sideMenuNavigationController!.setNavigationBarHidden(true, animated: true)
                case 1:
                    sideMenuNavigationController2!.setNavigationBarHidden(true, animated: true)
                case 2:
                    sideMenuNavigationController3!.setNavigationBarHidden(true, animated: true)
                default:
                    break
                }*/
                tabController!.setTabBarVisible(false, animated: true)
                }, completion: nil)
            
            if self.delegate != nil {
                if self.delegate!.videoMaximized != nil {
                    self.delegate!.videoMaximized!(self)
                }
            }
            self.PlayButton.cheetah.alpha(0.0).duration(0.2).run().completion({
                self.playFromCurrentTime()
            })
            self.resetButton.cheetah.alpha(0.0).duration(0.2).run()
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

// KVO player layer keys

private let PlayerReadyForDisplayKey = "readyForDisplay"

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
                //self.placeHolderImage.generateThumbImage(self.resource)
                if item.playbackLikelyToKeepUp && self.playbackState == .Playing {
                    self.playFromCurrentTime()
                }
            }
            let status = (change?[NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.playerController.player = self.player
            //self.playerView.playerLayer.hidden = false
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
        case (.Some(PlayerReadyForDisplayKey), &PlayerLayerObserverContext):
            if self.playerController.readyForDisplay {
                if self.delegate != nil {
                    self.delegate?.playerReady(self)
                }
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}



//
//  NPProgressLabel.swift
//  NPProgressLabelExample
//
//  Created by Nestor Popko on 3/7/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

@IBDesignable
final public class NPProgressLabel: UIView {
    
    // MARK: public properties and methods
    @IBInspectable public var  text: String? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public var textAlignment: NSTextAlignment = .Center {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable public var textColor: UIColor = UIColor.blackColor() {
        didSet {
            strokedLayer.backgroundColor = textColor.CGColor
            filledLayer.backgroundColor = textColor.CGColor
        }
    }
    
    public var font = UIFont.systemFontOfSize(14.0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var fontName: String {
        get {
            return font.fontName
        }
        
        set {
            if let font = UIFont(name: newValue, size: fontSize) {
                self.font = font
            }
        }
    }
    
    @IBInspectable public var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        
        set {
            if let font = UIFont(name: fontName, size: newValue) {
                self.font = font
            }
        }
    }
    
    @IBInspectable public var lineWidth: CGFloat = 1.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var progress: CGFloat = 0.0 {
        didSet {
            layoutLayers()
        }
    }
    
    public func setProgress(progress: CGFloat, animated: Bool = false) {
        if !animated {
            self.progress = progress
            return
        }
        
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = NSValue(CGRect: filledLayer.bounds)
        animation.toValue = NSValue(CGRect: CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height))
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.progress = progress
        filledLayer.addAnimation(animation, forKey: nil)
    }
    
    // MARK: private properties
    private let strokedLayer = CALayer()
    private let filledLayer = CALayer()
    private var textAttributes: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        return [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
    }
    
    
    // MARK: initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        strokedLayer.anchorPoint = CGPointZero
        strokedLayer.backgroundColor = textColor.CGColor
        layer.addSublayer(strokedLayer)
        
        filledLayer.anchorPoint = CGPointZero
        filledLayer.backgroundColor = textColor.CGColor
        layer.addSublayer(filledLayer)
    }
    
    // MARK: layout
    override public func intrinsicContentSize() -> CGSize {
        if let text = text {
            let size = NSAttributedString(string: text, attributes: textAttributes).size()
            return CGSize(width: ceil(size.width) + lineWidth, height: ceil(size.height) + lineWidth)
        }
        return CGSizeZero
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutLayers()
        updateTextMask()
    }
    
    private func layoutLayers() {
        strokedLayer.frame = bounds
        filledLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
    
    // MARK: drawing
    private func updateTextMask() {
        let strokedMask = CALayer()
        strokedMask.contentsGravity = kCAGravityResizeAspect
        strokedMask.frame = bounds
        strokedMask.contents = renderTextWithDrawingMode(.Stroke)
        strokedLayer.mask = strokedMask
        
        let filledMask = CALayer()
        filledMask.contentsGravity = kCAGravityResizeAspect
        filledMask.frame = bounds
        filledMask.contents = renderTextWithDrawingMode(.FillStroke)
        filledLayer.mask = filledMask
    }
    
    private func renderTextWithDrawingMode(mode: CGTextDrawingMode) -> CGImage? {
        guard let text = text else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetTextDrawingMode(context!, mode)
        CGContextSetLineWidth(context!, lineWidth)
        
        text.drawInRect(bounds, withAttributes: textAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.CGImage
    }
}

//
//  UIImage+Gradient.swift
//  NPGradientImageExample
//
//  Created by Nestor Popko on 3/7/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

extension UIImage {
    static func gradientImage(colors colors: [UIColor], locations: [CGFloat], size: CGSize, horizontal: Bool = false) -> UIImage {
        let endPoint = horizontal ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 0.0, y: 1.0)
        return gradientImage(colors: colors, locations: locations, startPoint: CGPointZero, endPoint: endPoint, size: size)
    }
    
    static func gradientImage(colors colors: [UIColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!);
        
        let components = colors.reduce([]) { (currentResult: [CGFloat], currentColor: UIColor) -> [CGFloat] in
            var result = currentResult
            
            let numberOfComponents = CGColorGetNumberOfComponents(currentColor.CGColor)
            let components = CGColorGetComponents(currentColor.CGColor)
            if numberOfComponents == 2 {
                result.appendContentsOf([components[0], components[0], components[0], components[1]])
            } else {
                result.appendContentsOf([components[0], components[1], components[2], components[3]])
            }
            
            return result
        }
        
        let gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), components, locations, colors.count);
        
        let transformedStartPoint = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
        let transformedEndPoint = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)
        CGContextDrawLinearGradient(context!, gradient!, transformedStartPoint, transformedEndPoint, []);
        UIGraphicsPopContext();
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return gradientImage!
    }
}

