//
//  VideoMakerRootViewController.swift
//  VideoMaker
//
//  Created by Tom on 10/24/15.
//  Copyright © 2015 Tom. All rights reserved.
//

import UIKit
import NKRecorder

class ExampleVideoMakerViewController: UIViewController {
    var recorderVC: NKRecorderViewController = NKRecorderViewController.mainNavController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorderVC.recorderDelegate = self
        addChildViewController(recorderVC)
        view.addSubview(recorderVC.view)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension ExampleVideoMakerViewController: NKRecorderDelegate {
    func willStartRecording(recorderViewController: NKRecorderViewController) {
        
    }
    
    func didCancelRecording(recorderViewController: NKRecorderViewController) {
        
    }
    
    func didProduceVideo(recorderViewController: NKRecorderViewController, videoSession: NKVideoSession) {
        recorderVC.pause()
        videoSession.export() { (outputURL) in
            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path!, self, "video:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func video(videoPath: NSString?, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<()>) {
        recorderVC.play()
        if (error == nil) {
            UIAlertView(title: "Saved to camera roll", message:"", delegate: nil, cancelButtonTitle: "Done").show()
        } else {
            UIAlertView(title: "Failed to save", message: "'", delegate: nil, cancelButtonTitle: "Okay").show()
        }
    }
}