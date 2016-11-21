//
//  VideoPlayer.swift
//  ToothSense
//
//  Created by Dillon Murphy on 11/21/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import UIKit
import Foundation
import AVFoundation
import CoreGraphics
import AudioToolbox


extension UIResponder {
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
}

public struct VideoConfiguration {
    public static var playButtonImage: UIImage = UIImage(named: "PlayButton")!
    public static var pauseButtonImage: UIImage = UIImage(named: "PauseButton")!
    public static var beginningButtonImage: UIImage = UIImage(named: "BeginningButton")!
    public static var muteButtonImage: UIImage = UIImage(named: "Mute")!
    public static var unmuteButtonImage: UIImage = UIImage(named: "Unmute")!
    public static var maxButtonImage: UIImage = UIImage(named: "maximize")!
    public static var minButtonImage: UIImage = UIImage(named: "minimize")!
    
    public static var animation: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseOut
    public static var animationDelay: NSTimeInterval = 0.3
    public static var animationDuration: NSTimeInterval = 0.3
    
    public static var buttonTintColor: UIColor = UIColor.whiteColor()
    public static var playerBackgroundColor: UIColor = UIColor(white: 0.05, alpha: 0.9)
    public static var barColor: UIColor = UIColor(white: 0.9, alpha: 0.8)
    
    public static var tapToPlay: Bool = true
    public static var showControls: Bool = true
    
}

public enum VideoPlayerState: Int, CustomStringConvertible {
    case Stopped = 0
    case Playing
    case Paused
    case Failed
    public var description: String {
        get {
            switch self {
            case .Stopped:
                return "Stopped"
            case .Playing:
                return "Playing"
            case .Failed:
                return "Failed"
            case .Paused:
                return "Paused"
            }
        }
    }
}

public enum VideoPlayerBufferingState: Int, CustomStringConvertible {
    case Unknown = 0
    case Ready
    case Delayed
    public var description: String {
        get {
            switch self {
            case .Unknown:
                return "Unknown"
            case .Ready:
                return "Ready"
            case .Delayed:
                return "Delayed"
            }
        }
    }
}

// MARK: - VideoPlayerDelegate

public protocol VideoPlayerDelegate: NSObjectProtocol {
    func videoPlayerReady(videoPlayer: VideoPlayer)
    func videoPlayerMuted(videoPlayer: VideoPlayer, muted: Bool)
    func videoPlayerPlaybackStateDidChange(videoPlayer: VideoPlayer, state: VideoPlayerState)
    func videoPlayerBufferingStateDidChange(videoPlayer: VideoPlayer, state: VideoPlayerBufferingState)
    func videoPlayerCurrentTimeDidChange(videoPlayer: VideoPlayer)
    func videoPlayerPlaybackFromBeginning(videoPlayer: VideoPlayer)
    func videoPlayerPlaybackEnded(videoPlayer: VideoPlayer)
    func videoPlayerTapped(videoPlayer: VideoPlayer)
}

// MARK: - VideoPlayer

public class VideoPlayer: UIView {
    
    // MARK: - public instance vars
    
    public weak var delegate: VideoPlayerDelegate?
    
    public var controlView: UIStackView = UIStackView(frame: CGRect.zero)
    public var controlViewBackground: UIView = UIView(frame: CGRect.zero)
    public var mutedButton: UIButton = UIButton(type: UIButtonType.Custom)
    public var maxMiniButton: UIButton = UIButton(type: UIButtonType.Custom)
    public var playPauseButton: UIButton = UIButton(type: UIButtonType.Custom)
    public var beginningButton: UIButton = UIButton(type: UIButtonType.Custom)
    public var videoSlider: UISlider = UISlider(frame: CGRect.zero)
    public var bufferSize: Double = 10
    
    //var shapePath : ShapeLoader!
    
    public var fillMode: String {
        get {
            return self.playerLayer.videoGravity
        }
        set {
            self.playerLayer.videoGravity = newValue
        }
    }
    
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
    
    public var videoPlayerState: VideoPlayerState = .Stopped {
        didSet {
            if videoPlayerState != oldValue {
                self.delegate?.videoPlayerPlaybackStateDidChange(self, state: self.videoPlayerState)
            }
        }
    }
    
    public var videoPlayerBufferingState: VideoPlayerBufferingState = .Unknown {
        didSet {
            if videoPlayerBufferingState != oldValue {
                self.delegate?.videoPlayerBufferingStateDidChange(self, state: self.videoPlayerBufferingState)
            }
        }
    }
    
    // MARK: - private instance vars
    
    private var asset: AVAsset?
    internal var playerItem: AVPlayerItem?
    internal var originalFrame: CGRect?
    internal var timeObserver: AnyObject!
    
    public var player: AVPlayer! {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
            playerLayer.player!.actionAtItemEnd = .Pause
        }
    }
    
    public var sliderValue: Float {
        get {
            return Float(self.currentTime/self.maximumDuration)
        }
    }
    
    public var playerLayer: AVPlayerLayer {
        layer.backgroundColor = VideoConfiguration.playerBackgroundColor.CGColor
        layer.fillMode = AVLayerVideoGravityResizeAspectFill
        return layer as! AVPlayerLayer
    }
    
    override public class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    // MARK: - object lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createPlayerLayer(
            CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.originalFrame = frame
        self.createPlayerLayer(
            frame)
    }
    
    let progressLayer: CAShapeLayer = CAShapeLayer()
    var progressTimer: NSTimer?
    
    func startProgress() {
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        progressLayer.lineWidth = 10.0
        progressLayer.bounds = CGRect(x: self.bounds.midX-187, y: self.bounds.midY, width: 202, height: 202)
        //progressLayer.borderColor = UIColor.wheatColor().CGColor
        //progressLayer.borderWidth = 1.0
        progressLayer.position = CGPoint(x:self.center.x, y: self.center.y)
        self.layer.addSublayer(progressLayer)
        progressLayer.path = self.getPlay().CGPath
        self.regularPlay()
    }
    
    func regularPlay() {
        self.animateProgressView()
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(self.animateProgressView), userInfo: nil, repeats: true)
    }
    func stopLoading() {
        if progressTimer != nil && progressTimer!.valid {
            progressTimer!.invalidate()
            progressTimer = nil
        }
    }
    
    func animateProgressView() {
        let sameDur = 1.5
        progressLayer.strokeEnd = 0.0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = sameDur
        animation.fillMode = kCAFillModeForwards
        let animation2 = CABasicAnimation(keyPath: "opacity")
        animation2.fromValue = 1.0
        animation2.toValue = 0.7
        animation2.duration = 1.0
        animation2.fillMode = kCAFillModeForwards
        let groupAnimations = CAAnimationGroup()
        groupAnimations.duration = sameDur
        groupAnimations.animations = [animation, animation2]
        groupAnimations.removedOnCompletion = false
        progressLayer.addAnimation(groupAnimations, forKey: "groupAnimations")
        self.delay(1.0 * Double(NSEC_PER_SEC)) {
            let animation3 = CABasicAnimation(keyPath: "opacity")
            animation3.fromValue = 0.7
            animation3.toValue = 1.0
            animation3.duration = 1.0
            animation3.fillMode = kCAFillModeForwards
            self.progressLayer.addAnimation(animation3, forKey: "opacity")
        }
    }
    
    deinit {
        removeObservers()
        self.playerLayer.player = nil
        self.delegate = nil
        self.player.pause()
        if self.videoPlayerState == .Playing {
            self.pause()
        }
        self.setupPlayerItem(nil)
        stopLoading()
    }
    
    // MARK: - functions
    
    func removeObservers() {
        self.player.removeTimeObserver(timeObserver)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.playerLayer.removeObserver(self, forKeyPath: "readyForDisplay", context: &PlayerLayerObserverContext)
        self.player.removeObserver(self, forKeyPath: "rate", context: &PlayerObserverContext)
    }
    
    var checkTimer : Float = 0.0
    
    func addObservers() {
        self.playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerLayerObserverContext)
        self.player.addObserver(self, forKeyPath: "rate", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]) , context: &PlayerObserverContext)
        self.timeObserver = self.player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (timeInterval) in
            if self.checkTimer == Float(CMTimeGetSeconds(timeInterval)) && self.controlView.alpha != 0 {
                UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                    self.controlView.alpha = 0.0
                    self.controlViewBackground.alpha = 0.0
                }, completion: nil)
            }
            if self.controlView.alpha != 0 {
                self.checkTimer = Float(CMTimeGetSeconds(timeInterval)) + 3.5
            }
            self.videoSlider.setValue(self.sliderValue, animated: true)
            self.delegate?.videoPlayerCurrentTimeDidChange(self)
        })
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.applicationWillResignActive), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
    }
    
    public func addURL(videoURL: NSURL, rect: CGRect, view: UIView) {
        self.frame = rect
        self.setUrl(videoURL)
        view.addSubview(self)
    }
    
    public func playFromBeginning() {
        self.delegate?.videoPlayerPlaybackFromBeginning(self)
        self.player.seekToTime(kCMTimeZero)
        self.playFromCurrentTime()
    }
    
    public func playFromCurrentTime() {
        self.videoPlayerState = .Playing
        self.player.play()
        self.playPauseButton.selected = true
    }
    
    public func pause() {
        if self.videoPlayerState != .Playing {
            return
        }
        self.player.pause()
        self.playPauseButton.selected = false
        self.videoPlayerState = .Paused
    }
    
    public func stop() {
        if self.videoPlayerState == .Stopped {
            return
        }
        self.player.pause()
        self.playPauseButton.selected = false
        self.videoPlayerState = .Stopped
        self.delegate?.videoPlayerPlaybackEnded(self)
    }
    
    public func seekToTime(time: CMTime) {
        if let playerItem = self.playerItem {
            return playerItem.seekToTime(time)
        }
    }
    
    public func createPlayerLayer(frame: CGRect) {
        self.player = AVPlayer()
        addObservers()
        if VideoConfiguration.showControls {
            addControls(true, playpauseButton: true, beginButton: true, maxMinButton: true, slider: true, color: VideoConfiguration.barColor)
        }
        if VideoConfiguration.tapToPlay {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedVideo(_:))))
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedVideoPlay(_:)))
            doubleTap.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap)
        }
        //addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .Equal, toItem: shapePath, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        //addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .Equal, toItem: shapePath, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    public func tappedVideo(sender: UITapGestureRecognizer) {
        if !controlViewBackground.frame.contains(sender.locationInView(self)) {
            if controlView.alpha != 0.0 {
                UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                    self.controlView.alpha = 0.0
                    self.controlViewBackground.alpha = 0.0
                }, completion: nil)
            } else {
                UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                    self.controlView.alpha = 1.0
                    self.controlViewBackground.alpha = 1.0
                }, completion: nil)
            }
        }
    }
    
    public func tappedVideoPlay(sender: UITapGestureRecognizer) {
        if self.videoPlayerState != .Playing {
            self.playPauseButton.enabled = false
            self.playFromCurrentTime()
            UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                self.controlView.alpha = 0.0
                self.controlViewBackground.alpha = 0.0
            }, completion: nil)
        } else {
            self.pause()
        }
        self.delegate?.videoPlayerTapped(self)
    }
    
    public func setUrl(url: NSURL) {
        if(self.videoPlayerState == .Playing){
            self.pause()
        }
        self.setupPlayerItem(nil)
        let asset = AVURLAsset(URL: url, options: .None)
        self.setupAsset(asset)
    }
    
    func addControls(muteButton: Bool, playpauseButton: Bool, beginButton: Bool, maxMinButton: Bool, slider: Bool, color: UIColor?) {
        controlViewBackground = UIView(frame: CGRect(x: 0, y: self.bounds.maxY - 40, width: self.bounds.width, height: 40))
        controlViewBackground.backgroundColor = color
        addSubview(controlViewBackground)
        controlView = UIStackView(frame: CGRect(x: 5, y: self.bounds.maxY - 35, width: self.bounds.width - 10, height: 30))
        controlView.distribution = UIStackViewDistribution.Fill
        controlView.axis = UILayoutConstraintAxis.Horizontal
        controlView.backgroundColor = UIColor(white: 0.5, alpha: 0.2)
        controlView.spacing = 10
        addSubview(controlView)
        if beginButton {
            beginningButton.frame = CGRect(x: 15, y: self.bounds.maxY - 35, width: 30, height: 30)
            beginningButton.setImage(VideoConfiguration.beginningButtonImage, forState: .Normal)
            beginningButton.addTarget(self, action: #selector(VideoPlayer.beginningAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            beginningButton.tintColor = VideoConfiguration.buttonTintColor
            let heightBeginButton = NSLayoutConstraint(item: beginningButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            let widthBeginButton = NSLayoutConstraint(item: beginningButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            beginningButton.addConstraint(heightBeginButton)
            beginningButton.addConstraint(widthBeginButton)
            controlView.addArrangedSubview(beginningButton)
        }
        if playpauseButton {
            playPauseButton.frame = CGRect(x: 0, y: self.bounds.maxY - 35, width: 30, height: 30)
            playPauseButton.setImage(VideoConfiguration.playButtonImage, forState: .Normal)
            playPauseButton.setImage(VideoConfiguration.pauseButtonImage, forState: .Selected)
            playPauseButton.addTarget(self, action: #selector(VideoPlayer.playPauseAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            playPauseButton.tintColor = VideoConfiguration.buttonTintColor
            let heightPlayButton = NSLayoutConstraint(item: playPauseButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            let widthPlayButton = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            playPauseButton.addConstraint(heightPlayButton)
            playPauseButton.addConstraint(widthPlayButton)
            controlView.addArrangedSubview(playPauseButton)
        }
        if slider {
            videoSlider = UISlider(frame: CGRect(x: 0, y: self.bounds.maxY - 35, width: 200, height: 30))
            videoSlider.setThumbImage(VideoConfiguration.playButtonImage, forState: UIControlState.Normal)
            videoSlider.thumbTintColor = VideoConfiguration.buttonTintColor
            videoSlider.minimumTrackTintColor = UIColor.darkGrayColor()
            videoSlider.maximumTrackTintColor = UIColor.whiteColor()
            videoSlider.maximumValue = 1.0
            videoSlider.minimumValue = 0
            videoSlider.continuous = true
            videoSlider.tintColor = .clearColor()
            videoSlider.backgroundColor = .clearColor()
            videoSlider.value = sliderValue
            videoSlider.addTarget(self, action: #selector(self.videoSliderValueChanged(_:)), forControlEvents: .ValueChanged)
            videoSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(_:))))
            let heightSlider = NSLayoutConstraint(item: videoSlider, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            videoSlider.addConstraint(heightSlider)
            if muteButton {
                let rightSlider = NSLayoutConstraint(item: videoSlider, attribute: .Trailing, relatedBy: .Equal, toItem: mutedButton, attribute: .Trailing, multiplier: 1.0, constant: -5)
                addConstraint(rightSlider)
            }
            controlView.addArrangedSubview(videoSlider)
        }
        if muteButton {
            mutedButton.frame = CGRect(x: 0, y: self.bounds.maxY - 35, width: 30, height: 30)
            mutedButton.setImage(VideoConfiguration.muteButtonImage, forState: .Normal)
            mutedButton.setImage(VideoConfiguration.unmuteButtonImage, forState: .Selected)
            mutedButton.addTarget(self, action: #selector(VideoPlayer.muteAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            mutedButton.tintColor = VideoConfiguration.buttonTintColor
            let heightMuteButton = NSLayoutConstraint(item: mutedButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            let widthMuteButton = NSLayoutConstraint(item: mutedButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            mutedButton.addConstraint(heightMuteButton)
            mutedButton.addConstraint(widthMuteButton)
            controlView.addArrangedSubview(mutedButton)
        }
        if maxMinButton {
            maxMiniButton.frame = CGRect(x: 0, y: self.bounds.maxY - 35, width: 30, height: 30)
            maxMiniButton.setImage(VideoConfiguration.maxButtonImage, forState: .Normal)
            maxMiniButton.setImage(VideoConfiguration.minButtonImage, forState: .Selected)
            maxMiniButton.addTarget(self, action: #selector(VideoPlayer.maxMiniAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            maxMiniButton.tintColor = VideoConfiguration.buttonTintColor
            let heightMuteButton = NSLayoutConstraint(item: maxMiniButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            let widthMuteButton = NSLayoutConstraint(item: maxMiniButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            maxMiniButton.addConstraint(heightMuteButton)
            maxMiniButton.addConstraint(widthMuteButton)
            controlView.addArrangedSubview(maxMiniButton)
        }
    }
    
    public func sliderTapped(gestureRecognizer: UITapGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.locationInView(self.videoSlider)
        let widthOfSlider: CGFloat = videoSlider.frame.width
        let newValue = ((pointTapped.x) * CGFloat(videoSlider.maximumValue) / widthOfSlider)
        videoSlider.setValue(Float(newValue), animated: true)
        guard let timescale = player?.currentItem?.duration.timescale else {
            return
        }
        let sliderTime: CMTime = CMTimeMakeWithSeconds(Double(newValue) * self.maximumDuration, timescale)
        self.seekToTime(sliderTime)
    }
    
    func videoSliderValueChanged(sender: UISlider) {
        guard let timescale = player?.currentItem?.duration.timescale else {
            return
        }
        let sliderTime: CMTime = CMTimeMakeWithSeconds(Double(sender.value) * self.maximumDuration, timescale)
        self.seekToTime(sliderTime)
    }
    
    func beginningAction(sender:UIButton) {
        self.seekToTime(kCMTimeZero)
    }
    
    func maxMiniAction(sender:UIButton) {
        if sender.selected {
            sender.selected = false
            if self.frame != self.originalFrame! {
                UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                    self.frame = self.originalFrame!
                    self.controlViewBackground.frame = CGRect(x: 0, y: self.bounds.maxY - 40, width: self.bounds.width, height: 40)
                    self.controlView.frame = CGRect(x: 5, y: self.bounds.maxY - 35, width: self.bounds.width - 10, height: 30)
                }, completion: nil)
            }
        } else {
            sender.selected = true
            if self.superview != nil {
                if self.frame != self.superview!.bounds {
                    UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                        self.frame = self.superview!.bounds
                        self.controlViewBackground.frame = CGRect(x: 0, y: self.bounds.maxY - 40, width: self.bounds.width, height: 40)
                        self.controlView.frame = CGRect(x: 5, y: self.bounds.maxY - 35, width: self.bounds.width - 10, height: 30)
                    }, completion: nil)
                }
            } else {
                if self.frame != screenBounds {
                    UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                        self.frame = screenBounds
                        self.controlViewBackground.frame = CGRect(x: 0, y: self.bounds.maxY - 40, width: self.bounds.width, height: 40)
                        self.controlView.frame = CGRect(x: 5, y: self.bounds.maxY - 35, width: self.bounds.width - 10, height: 30)
                    }, completion: nil)
                }
            }
        }
    }
    
    func playPauseAction(sender:UIButton) {
        if sender.selected {
            sender.selected = false
            self.pause()
        } else {
            sender.selected = true
            //activityIndicatorView.startAnimation()
            UIView.animateWithDuration(VideoConfiguration.animationDuration, delay: VideoConfiguration.animationDelay, options: VideoConfiguration.animation, animations: {
                self.controlView.alpha = 0.0
                self.controlViewBackground.alpha = 0.0
            }, completion: { _ in
                if self.player.currentTime() == kCMTimeZero {
                    self.playFromBeginning()
                } else {
                    self.playFromCurrentTime()
                }
            })
        }
    }
    
    func muteAction(sender:UIButton) {
        if self.player.muted == true {
            sender.selected = false
            self.player.muted = false
        } else {
            sender.selected = true
            self.player.muted = true
        }
        self.delegate?.videoPlayerMuted(self, muted: sender.selected)
    }
    
    
    // MARK: - private functions
    
    private func setupAsset(asset: AVAsset) {
        if self.videoPlayerState == .Playing {
            self.pause()
        }
        self.videoPlayerBufferingState = .Unknown
        self.asset = asset
        if self.asset != nil {
            self.setupPlayerItem(nil)
            let keys: [String] = ["tracks", "playable", "duration"]
            self.asset?.loadValuesAsynchronouslyForKeys(keys) {
                //dispatch_async(dispatch_get_main_queue(), {
                for key in keys {
                    var error: NSError?
                    let status = self.asset!.statusOfValueForKey(key, error: &error)
                    if status == .Failed {
                        self.videoPlayerState = .Failed
                        return
                    }
                }
                if self.asset!.playable == false {
                    self.videoPlayerState = .Failed
                    return
                }
                let playerItem: AVPlayerItem = AVPlayerItem(asset:self.asset!)
                self.setupPlayerItem(playerItem)
                //})
            }
        }
    }
    
    private func setupPlayerItem(playerItem: AVPlayerItem?) {
        if self.playerItem != nil {
            self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: "status", context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: &PlayerItemObserverContext)
            NSNotificationCenter.defaultCenter()
                .removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
            NSNotificationCenter.defaultCenter()
                .removeObserver(self, name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.playerItem)
        }
        self.playerItem = playerItem
        if self.playerItem != nil {
            self.playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: "status", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoPlayerItemDidPlayToEndTime), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoPlayerItemFailedToPlayToEndTime(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.playerItem)
        }
        self.player.replaceCurrentItemWithPlayerItem(self.playerItem)
    }
}

// MARK: - NSNotifications

extension VideoPlayer {
    public func videoPlayerItemDidPlayToEndTime(aNotification: NSNotification) {
        self.player.seekToTime(kCMTimeZero, completionHandler: { _ in
            self.stop()
        })
    }
    
    public func videoPlayerItemFailedToPlayToEndTime(aNotification: NSNotification) {
        self.videoPlayerState = .Failed
    }
    
    public func applicationWillResignActive(aNotification: NSNotification) {
        if self.videoPlayerState == .Playing {
            self.pause()
        }
    }
    
    public func applicationDidEnterBackground(aNotification: NSNotification) {
        if self.videoPlayerState == .Playing {
            self.pause()
        }
    }
    
    public func applicationWillEnterForeground(aNoticiation: NSNotification) {
        if self.videoPlayerState == .Paused {
            self.playFromCurrentTime()
        }
    }
}

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

extension VideoPlayer {
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &PlayerItemObserverContext) {
            if keyPath == "status" {
                if let item = self.playerItem {
                    self.videoPlayerBufferingState = .Ready
                    if item.playbackLikelyToKeepUp && self.videoPlayerState == .Playing {
                        self.playFromCurrentTime()
                    }
                }
                let status = Int(change?[NSKeyValueChangeNewKey] as! NSNumber)
                switch (status) {
                case AVPlayerStatus.ReadyToPlay.rawValue:
                    self.playerLayer.player = self.player
                    self.playerLayer.hidden = false
                case AVPlayerStatus.Failed.rawValue:
                    self.videoPlayerState = VideoPlayerState.Failed
                default:
                    break
                }
            } else if keyPath == "playbackBufferEmpty" {
                if let item = self.playerItem {
                    if item.playbackBufferEmpty {
                        print("playbackBufferEmpty")
                        self.videoPlayerBufferingState = .Delayed
                    }
                }
                let status = Int(change?[NSKeyValueChangeNewKey] as! NSNumber)
                switch (status) {
                case AVPlayerStatus.ReadyToPlay.rawValue:
                    self.playerLayer.player = self.player
                    self.playerLayer.hidden = false
                case AVPlayerStatus.Failed.rawValue:
                    self.videoPlayerState = VideoPlayerState.Failed
                default:
                    break
                }
            } else if keyPath == "loadedTimeRanges" {
                if let item = self.playerItem {
                    self.videoPlayerBufferingState = .Ready
                    let timeRanges = item.loadedTimeRanges
                    let timeRange: CMTimeRange = timeRanges[0].CMTimeRangeValue
                    let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
                    let currentTime = CMTimeGetSeconds(item.currentTime())
                    if (bufferedTime - currentTime) >= self.bufferSize && self.videoPlayerState == .Playing {
                        self.playFromCurrentTime()
                    }
                }
            }
        } else if (context == &PlayerObserverContext) {
            if keyPath == "rate" {
            } else if keyPath == "tracks" {
            } else if keyPath == "playable" {
            } else if keyPath == "duration" {
            }
        } else if (context == &PlayerLayerObserverContext) {
            if self.playerLayer.readyForDisplay {
                self.delegate?.videoPlayerReady(self)
            }
        }
    }
}


public extension UIView  {
    
    func getVideoPaths() -> [UIBezierPath] {
        var paths: [UIBezierPath] = [UIBezierPath]()
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 221.87, y: 0))
        bezierPath.addLineToPoint(CGPoint(x: 36.5, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: 19, y: 17.5), controlPoint1: CGPoint(x: 26.85, y: 0), controlPoint2: CGPoint(x: 19, y: 7.85))
        bezierPath.addLineToPoint(CGPoint(x: 19, y: 240.87))
        bezierPath.addCurveToPoint(CGPoint(x: 36.5, y: 258.37), controlPoint1: CGPoint(x: 19, y: 250.52), controlPoint2: CGPoint(x: 26.85, y: 258.37))
        bezierPath.addLineToPoint(CGPoint(x: 221.87, y: 258.37))
        bezierPath.addCurveToPoint(CGPoint(x: 239.37, y: 240.87), controlPoint1: CGPoint(x: 231.52, y: 258.37), controlPoint2: CGPoint(x: 239.37, y: 250.52))
        bezierPath.addLineToPoint(CGPoint(x: 239.37, y: 17.5))
        bezierPath.addCurveToPoint(CGPoint(x: 221.87, y: 0), controlPoint1: CGPoint(x: 239.37, y: 7.85), controlPoint2: CGPoint(x: 231.52, y: 0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 55.69, y: 124.19))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 124.19))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 88.85))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 88.85))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 124.19))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 34, y: 134.19))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 134.19))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 169.52))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 169.52))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 134.19))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 55.69, y: 78.85))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 78.85))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 78.85))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 34, y: 179.52))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 179.52))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 179.52))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 70.69, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 43.52))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 224.37, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 78.85))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 78.85))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 213.87, y: 43.52))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 43.52))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 203.37, y: 88.85))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 88.85))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 124.19))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 124.19))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 88.85))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 203.37, y: 134.19))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 134.19))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 169.52))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 169.52))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 134.19))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 188.37, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 15))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 15))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 33.52))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 188.37, y: 224.85))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 243.37))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 243.37))
        bezierPath.addLineToPoint(CGPoint(x: 70.69, y: 224.86))
        bezierPath.addLineToPoint(CGPoint(x: 188.37, y: 224.85))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 203.37, y: 179.52))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 179.52))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 214.86))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 179.52))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 224.37, y: 17.5))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 213.87, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 15))
        bezierPath.addLineToPoint(CGPoint(x: 221.87, y: 15))
        bezierPath.addCurveToPoint(CGPoint(x: 224.37, y: 17.5), controlPoint1: CGPoint(x: 223.22, y: 15), controlPoint2: CGPoint(x: 224.37, y: 16.15))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 36.5, y: 15))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 15))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 33.52))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 17.5))
        bezierPath.addCurveToPoint(CGPoint(x: 36.5, y: 15), controlPoint1: CGPoint(x: 34, y: 16.15), controlPoint2: CGPoint(x: 35.15, y: 15))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 34, y: 240.87))
        bezierPath.addLineToPoint(CGPoint(x: 34, y: 224.86))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 224.86))
        bezierPath.addLineToPoint(CGPoint(x: 55.69, y: 243.37))
        bezierPath.addLineToPoint(CGPoint(x: 36.5, y: 243.37))
        bezierPath.addCurveToPoint(CGPoint(x: 34, y: 240.87), controlPoint1: CGPoint(x: 35.15, y: 243.37), controlPoint2: CGPoint(x: 34, y: 242.22))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 221.87, y: 243.37))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 243.37))
        bezierPath.addLineToPoint(CGPoint(x: 203.37, y: 224.86))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 224.86))
        bezierPath.addLineToPoint(CGPoint(x: 224.37, y: 240.87))
        bezierPath.addCurveToPoint(CGPoint(x: 221.87, y: 243.37), controlPoint1: CGPoint(x: 224.37, y: 242.22), controlPoint2: CGPoint(x: 223.22, y: 243.37))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        paths.append(bezierPath)
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: 129.03, y: 86.3))
        bezier2Path.addCurveToPoint(CGPoint(x: 86.15, y: 129.19), controlPoint1: CGPoint(x: 105.39, y: 86.3), controlPoint2: CGPoint(x: 86.15, y: 105.54))
        bezier2Path.addCurveToPoint(CGPoint(x: 129.03, y: 172.08), controlPoint1: CGPoint(x: 86.15, y: 152.84), controlPoint2: CGPoint(x: 105.39, y: 172.08))
        bezier2Path.addCurveToPoint(CGPoint(x: 171.92, y: 129.19), controlPoint1: CGPoint(x: 152.68, y: 172.08), controlPoint2: CGPoint(x: 171.92, y: 152.84))
        bezier2Path.addCurveToPoint(CGPoint(x: 129.03, y: 86.3), controlPoint1: CGPoint(x: 171.92, y: 105.54), controlPoint2: CGPoint(x: 152.68, y: 86.3))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(CGPoint(x: 129.03, y: 162.07))
        bezier2Path.addCurveToPoint(CGPoint(x: 96.15, y: 129.19), controlPoint1: CGPoint(x: 110.9, y: 162.07), controlPoint2: CGPoint(x: 96.15, y: 147.32))
        bezier2Path.addCurveToPoint(CGPoint(x: 129.03, y: 96.3), controlPoint1: CGPoint(x: 96.15, y: 111.05), controlPoint2: CGPoint(x: 110.9, y: 96.3))
        bezier2Path.addCurveToPoint(CGPoint(x: 161.92, y: 129.19), controlPoint1: CGPoint(x: 147.17, y: 96.3), controlPoint2: CGPoint(x: 161.92, y: 111.05))
        bezier2Path.addCurveToPoint(CGPoint(x: 129.03, y: 162.07), controlPoint1: CGPoint(x: 161.92, y: 147.32), controlPoint2: CGPoint(x: 147.17, y: 162.07))
        bezier2Path.closePath()
        bezier2Path.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        paths.append(bezierPath)
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.moveToPoint(CGPoint(x: 149.66, y: 122.26))
        bezier3Path.addLineToPoint(CGPoint(x: 124.98, y: 106.11))
        bezier3Path.addCurveToPoint(CGPoint(x: 120.24, y: 104.59), controlPoint1: CGPoint(x: 123.47, y: 105.12), controlPoint2: CGPoint(x: 121.83, y: 104.59))
        bezier3Path.addCurveToPoint(CGPoint(x: 113.06, y: 112.55), controlPoint1: CGPoint(x: 116.67, y: 104.59), controlPoint2: CGPoint(x: 113.06, y: 107.33))
        bezier3Path.addLineToPoint(CGPoint(x: 113.06, y: 145.82))
        bezier3Path.addCurveToPoint(CGPoint(x: 120.24, y: 153.78), controlPoint1: CGPoint(x: 113.06, y: 151.05), controlPoint2: CGPoint(x: 116.67, y: 153.78))
        bezier3Path.addCurveToPoint(CGPoint(x: 124.98, y: 152.27), controlPoint1: CGPoint(x: 121.83, y: 153.78), controlPoint2: CGPoint(x: 123.47, y: 153.26))
        bezier3Path.addLineToPoint(CGPoint(x: 149.66, y: 136.11))
        bezier3Path.addCurveToPoint(CGPoint(x: 153.64, y: 129.18), controlPoint1: CGPoint(x: 152.19, y: 134.45), controlPoint2: CGPoint(x: 153.64, y: 131.92))
        bezier3Path.addCurveToPoint(CGPoint(x: 149.66, y: 122.26), controlPoint1: CGPoint(x: 153.64, y: 126.44), controlPoint2: CGPoint(x: 152.19, y: 123.92))
        bezier3Path.closePath()
        bezier3Path.moveToPoint(CGPoint(x: 123.06, y: 141.57))
        bezier3Path.addLineToPoint(CGPoint(x: 123.06, y: 116.8))
        bezier3Path.addLineToPoint(CGPoint(x: 141.97, y: 129.18))
        bezier3Path.addLineToPoint(CGPoint(x: 123.06, y: 141.57))
        bezier3Path.closePath()
        bezier3Path.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        paths.append(bezierPath)
        return paths
    }
    
    func getVideoPath() -> [UIBezierPath] {
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        var paths: [UIBezierPath] = [UIBezierPath]()
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 64.02, y: 26))
        bezierPath.addCurveToPoint(CGPoint(x: 64, y: 25.92), controlPoint1: CGPoint(x: 64.02, y: 25.97), controlPoint2: CGPoint(x: 64, y: 25.94))
        bezierPath.addLineToPoint(CGPoint(x: 64, y: 8.91))
        bezierPath.addCurveToPoint(CGPoint(x: 57.17, y: 1.99), controlPoint1: CGPoint(x: 64, y: 5.1), controlPoint2: CGPoint(x: 60.93, y: 1.99))
        bezierPath.addLineToPoint(CGPoint(x: 6.81, y: 1.99))
        bezierPath.addCurveToPoint(CGPoint(x: -0.02, y: 8.91), controlPoint1: CGPoint(x: 3.05, y: 1.99), controlPoint2: CGPoint(x: -0.02, y: 5.1))
        bezierPath.addLineToPoint(CGPoint(x: -0.02, y: 55.09))
        bezierPath.addCurveToPoint(CGPoint(x: 6.81, y: 62.01), controlPoint1: CGPoint(x: -0.02, y: 58.9), controlPoint2: CGPoint(x: 3.05, y: 62.01))
        bezierPath.addLineToPoint(CGPoint(x: 57.17, y: 62.01))
        bezierPath.addCurveToPoint(CGPoint(x: 64, y: 55.09), controlPoint1: CGPoint(x: 60.93, y: 62.01), controlPoint2: CGPoint(x: 64, y: 58.9))
        bezierPath.addLineToPoint(CGPoint(x: 64, y: 26.08))
        bezierPath.addCurveToPoint(CGPoint(x: 64.02, y: 26), controlPoint1: CGPoint(x: 64, y: 26.06), controlPoint2: CGPoint(x: 64.02, y: 26.03))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 11.98, y: 35.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 35.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 27.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 27.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 35.98))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 11.98, y: 24.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 24.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 16.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 16.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 24.98))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 2, y: 38.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 38.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 46.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 46.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 38.02))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 14, y: 48.08))
        bezierPath.addCurveToPoint(CGPoint(x: 14.02, y: 48), controlPoint1: CGPoint(x: 14, y: 48.06), controlPoint2: CGPoint(x: 14.02, y: 48.03))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 47.92), controlPoint1: CGPoint(x: 14.02, y: 47.97), controlPoint2: CGPoint(x: 14, y: 47.94))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 37.08))
        bezierPath.addCurveToPoint(CGPoint(x: 14.02, y: 37), controlPoint1: CGPoint(x: 14, y: 37.06), controlPoint2: CGPoint(x: 14.02, y: 37.03))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 36.92), controlPoint1: CGPoint(x: 14.02, y: 36.97), controlPoint2: CGPoint(x: 14, y: 36.94))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 26.08))
        bezierPath.addCurveToPoint(CGPoint(x: 14.02, y: 26), controlPoint1: CGPoint(x: 14, y: 26.06), controlPoint2: CGPoint(x: 14.02, y: 26.03))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 25.92), controlPoint1: CGPoint(x: 14.02, y: 25.97), controlPoint2: CGPoint(x: 14, y: 25.94))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 15.08))
        bezierPath.addCurveToPoint(CGPoint(x: 14.02, y: 15), controlPoint1: CGPoint(x: 14, y: 15.06), controlPoint2: CGPoint(x: 14.02, y: 15.03))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 14.92), controlPoint1: CGPoint(x: 14.02, y: 14.97), controlPoint2: CGPoint(x: 14, y: 14.94))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 4.01))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 4.01))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 14.92))
        bezierPath.addCurveToPoint(CGPoint(x: 49.97, y: 15), controlPoint1: CGPoint(x: 49.98, y: 14.94), controlPoint2: CGPoint(x: 49.97, y: 14.97))
        bezierPath.addCurveToPoint(CGPoint(x: 49.98, y: 15.08), controlPoint1: CGPoint(x: 49.97, y: 15.03), controlPoint2: CGPoint(x: 49.98, y: 15.06))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 25.92))
        bezierPath.addCurveToPoint(CGPoint(x: 49.97, y: 26), controlPoint1: CGPoint(x: 49.98, y: 25.94), controlPoint2: CGPoint(x: 49.97, y: 25.97))
        bezierPath.addCurveToPoint(CGPoint(x: 49.98, y: 26.08), controlPoint1: CGPoint(x: 49.97, y: 26.03), controlPoint2: CGPoint(x: 49.98, y: 26.06))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 36.92))
        bezierPath.addCurveToPoint(CGPoint(x: 49.97, y: 37), controlPoint1: CGPoint(x: 49.98, y: 36.94), controlPoint2: CGPoint(x: 49.97, y: 36.97))
        bezierPath.addCurveToPoint(CGPoint(x: 49.98, y: 37.08), controlPoint1: CGPoint(x: 49.97, y: 37.03), controlPoint2: CGPoint(x: 49.98, y: 37.06))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 47.92))
        bezierPath.addCurveToPoint(CGPoint(x: 49.97, y: 48), controlPoint1: CGPoint(x: 49.98, y: 47.94), controlPoint2: CGPoint(x: 49.97, y: 47.97))
        bezierPath.addCurveToPoint(CGPoint(x: 49.98, y: 48.08), controlPoint1: CGPoint(x: 49.97, y: 48.03), controlPoint2: CGPoint(x: 49.98, y: 48.06))
        bezierPath.addLineToPoint(CGPoint(x: 49.98, y: 59.99))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 59.99))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 48.08))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 52, y: 27.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 27.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 35.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 35.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 27.02))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 52, y: 24.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 16.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 16.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 24.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 24.98))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 52, y: 38.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 38.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 46.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 46.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 38.02))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 61.98, y: 8.91))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 13.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 13.98))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 4.01))
        bezierPath.addLineToPoint(CGPoint(x: 57.17, y: 4.01))
        bezierPath.addCurveToPoint(CGPoint(x: 61.98, y: 8.91), controlPoint1: CGPoint(x: 59.82, y: 4.01), controlPoint2: CGPoint(x: 61.98, y: 6.21))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 6.81, y: 4.01))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 4.01))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 13.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 13.98))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 8.91))
        bezierPath.addCurveToPoint(CGPoint(x: 6.81, y: 4.01), controlPoint1: CGPoint(x: 2, y: 6.21), controlPoint2: CGPoint(x: 4.16, y: 4.01))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 2, y: 55.09))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 49.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 49.02))
        bezierPath.addLineToPoint(CGPoint(x: 11.98, y: 59.99))
        bezierPath.addLineToPoint(CGPoint(x: 6.81, y: 59.99))
        bezierPath.addCurveToPoint(CGPoint(x: 2, y: 55.09), controlPoint1: CGPoint(x: 4.16, y: 59.99), controlPoint2: CGPoint(x: 2, y: 57.79))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 57.17, y: 59.99))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 59.99))
        bezierPath.addLineToPoint(CGPoint(x: 52, y: 49.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 49.02))
        bezierPath.addLineToPoint(CGPoint(x: 61.98, y: 55.09))
        bezierPath.addCurveToPoint(CGPoint(x: 57.17, y: 59.99), controlPoint1: CGPoint(x: 61.98, y: 57.79), controlPoint2: CGPoint(x: 59.82, y: 59.99))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        paths.append(bezierPath)
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: 42.43, y: 31.12))
        bezier2Path.addLineToPoint(CGPoint(x: 26.43, y: 23.12))
        bezier2Path.addCurveToPoint(CGPoint(x: 25.48, y: 23.17), controlPoint1: CGPoint(x: 26.13, y: 22.97), controlPoint2: CGPoint(x: 25.77, y: 22.99))
        bezier2Path.addCurveToPoint(CGPoint(x: 25.01, y: 24), controlPoint1: CGPoint(x: 25.19, y: 23.35), controlPoint2: CGPoint(x: 25.01, y: 23.66))
        bezier2Path.addLineToPoint(CGPoint(x: 25.01, y: 40))
        bezier2Path.addCurveToPoint(CGPoint(x: 25.48, y: 40.83), controlPoint1: CGPoint(x: 25.01, y: 40.34), controlPoint2: CGPoint(x: 25.19, y: 40.65))
        bezier2Path.addCurveToPoint(CGPoint(x: 25.99, y: 40.98), controlPoint1: CGPoint(x: 25.63, y: 40.93), controlPoint2: CGPoint(x: 25.81, y: 40.98))
        bezier2Path.addCurveToPoint(CGPoint(x: 26.43, y: 40.87), controlPoint1: CGPoint(x: 26.14, y: 40.98), controlPoint2: CGPoint(x: 26.29, y: 40.94))
        bezier2Path.addLineToPoint(CGPoint(x: 42.43, y: 32.87))
        bezier2Path.addCurveToPoint(CGPoint(x: 42.97, y: 32), controlPoint1: CGPoint(x: 42.76, y: 32.71), controlPoint2: CGPoint(x: 42.97, y: 32.37))
        bezier2Path.addCurveToPoint(CGPoint(x: 42.43, y: 31.12), controlPoint1: CGPoint(x: 42.97, y: 31.63), controlPoint2: CGPoint(x: 42.76, y: 31.29))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(CGPoint(x: 26.97, y: 38.42))
        bezier2Path.addLineToPoint(CGPoint(x: 26.97, y: 25.58))
        bezier2Path.addLineToPoint(CGPoint(x: 39.8, y: 32))
        bezier2Path.addLineToPoint(CGPoint(x: 26.97, y: 38.42))
        bezier2Path.closePath()
        bezier2Path.miterLimit = 4
        fillColor.setFill()
        bezier2Path.fill()
        paths.append(bezier2Path)
        return paths
    }
    
    func getPlay() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 489.6, y: 81.6))
        bezierPath.addLineToPoint(CGPoint(x: 122.4, y: 81.6))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: 204), controlPoint1: CGPoint(x: 54.92, y: 81.6), controlPoint2: CGPoint(x: 0, y: 136.52))
        bezierPath.addLineToPoint(CGPoint(x: 0, y: 408))
        bezierPath.addCurveToPoint(CGPoint(x: 122.4, y: 530.4), controlPoint1: CGPoint(x: 0, y: 475.48), controlPoint2: CGPoint(x: 54.92, y: 530.4))
        bezierPath.addLineToPoint(CGPoint(x: 489.6, y: 530.4))
        bezierPath.addCurveToPoint(CGPoint(x: 612, y: 408), controlPoint1: CGPoint(x: 557.08, y: 530.4), controlPoint2: CGPoint(x: 612, y: 475.48))
        bezierPath.addLineToPoint(CGPoint(x: 612, y: 204))
        bezierPath.addCurveToPoint(CGPoint(x: 489.6, y: 81.6), controlPoint1: CGPoint(x: 612, y: 136.52), controlPoint2: CGPoint(x: 557.08, y: 81.6))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 217.6, y: 421.07))
        bezierPath.addLineToPoint(CGPoint(x: 416.91, y: 306.01))
        bezierPath.addLineToPoint(CGPoint(x: 217.6, y: 190.93))
        bezierPath.addLineToPoint(CGPoint(x: 217.6, y: 421.07))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        bezierPath.applyTransform(CGAffineTransformMakeScale(0.4,0.4))
        return bezierPath
    }
}
