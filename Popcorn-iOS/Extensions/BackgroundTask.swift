//
//  BackgroundTask.swift
//  Popcorn-iOS
//
//  Created by Antique on 8/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation

class BackgroundTask {
    
    // MARK: - Vars
    var player = AVAudioPlayer()
    var timer = Timer()
    
    // MARK: - Methods
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self, selector: #selector(interruptedAudio), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        player.stop()
    }
    
    @objc fileprivate func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification && notification.userInfo != nil {
            let info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 {
                playAudio()
            }
        }
    }
    
    fileprivate func playAudio() {
        guard let url = Bundle.main.path(forResource: "blank", ofType: "mp3") else {
            print("url not found")
            return
        }
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url), fileTypeHint: "mp3")
            self.player.volume = 1.0
            self.player.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
