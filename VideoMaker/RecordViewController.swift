//
//  ViewController.swift
//  VideoMaker
//
//  Created by Tom on 9/3/15.
//  Copyright (c) 2015 Tom. All rights reserved.
//

import UIKit
import SCRecorder

class RecordViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var tapToRecordView: UIView!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordingSpeedSegmentedControl: UISegmentedControl!

    var recorder: SCRecorder!
    var recordSession: SCRecordSession?
    var segmentTimeScale: [Float] = [] // each index corresponds to the time scale of a particular segment, used in VideoPlaybackViewController for speeding up/slowing down videos
// MARK: - View Controller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        recorder = SCRecorder()
        if !recorder.startRunning() {
            println("something went wrong: \(recorder.error)")
        }
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.previewView = previewView
        recorder.delegate = self
        tapToRecordView.addGestureRecognizer(RecordButtonTouchGestureRecognizer(target: self, action: "recordViewTouchDetected:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        prepareSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        recorder.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.stopRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Button Touch Handlers
    @IBAction func reverseCameraButtonPressed(sender: AnyObject) {
        recorder.switchCaptureDevices()
    }
    
    func recordViewTouchDetected(touchDetector: RecordButtonTouchGestureRecognizer) {
        if (touchDetector.state == .Began) {
            recorder.record()
        }
        else if (touchDetector.state == .Ended) {
            recorder.pause()
        }
    }
    
    @IBAction func recordingFinished(sender: AnyObject) {
        recorder.pause {
            if let session = self.recorder.session {
                self.recordSession = session
                self.showVideo()
            }
        }
    }
    
    @IBAction func retakeButtonPressed(sender: AnyObject) {
        if (recorder.session != nil) {
            recorder.pause()
            recorder.session?.cancelSession({})
            recorder.session = nil
            prepareSession()
        }
    }
    
    @IBAction func recordingSpeedValueChanged(sender: AnyObject) {
        let segmentedControl = sender as! UISegmentedControl
        
        println("Current timeScale: \(getVideoTimeScaleFromUISegment(segmentedControl.selectedSegmentIndex))")
    }
    
// MARK: - Misc
    func prepareSession() {
        if (recorder.session == nil)
        {
            var session = SCRecordSession()
            session.fileType = AVFileTypeMPEG4
            recorder.session = session
            segmentTimeScale = []
            updateRecordingTimeLabel()
        }
    }
    
    func showVideo() {
        performSegueWithIdentifier("Show Video", sender: self)
    }
    
    func updateRecordingTimeLabel() {
        if let duration = recorder.session?.duration {
            recordingTimeLabel.text = String(format: "Recording Time: %0.2f", CMTimeGetSeconds(duration))
        }
        else {
            recordingTimeLabel.text = "Recording Time: 0.00"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Show Video") {
            var videoPlaybackViewController: VideoPlaybackViewController = segue.destinationViewController as! VideoPlaybackViewController
            videoPlaybackViewController.recordSession = recordSession
            videoPlaybackViewController.segmentsRecordedTimeScale = segmentTimeScale
        }
    }
    
    func getVideoTimeScaleFromUISegment(index: Int) -> Float {
        var retTimeScale: Float
        switch (index) {
        case 0:
            retTimeScale = 4
        case 1:
            retTimeScale = 2
        case 2:
            retTimeScale = 1.0
        case 3:
            retTimeScale = 0.75
        case 4:
            retTimeScale = 0.5
        default:
            retTimeScale = 1.0
        }
        return retTimeScale
    }
}

extension RecordViewController: SCRecorderDelegate {
    
    func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        
        println("Reconfigured audio input: \(audioInputError)")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        println("Reconfigured video input: \(videoInputError)")
    }
    
    
    func recorder(recorder: SCRecorder, didSkipVideoSampleBufferInSession session: SCRecordSession) {
        println("Skipped video buffer")
    }
    

    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession)
    {
        updateRecordingTimeLabel()
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        if (error == nil) {
            segmentTimeScale.append(getVideoTimeScaleFromUISegment(recordingSpeedSegmentedControl.selectedSegmentIndex))
        }
    }
}