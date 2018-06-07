//
//  LoadTrackerListOperation.swift
//  Client
//
//  Created by Tim Palade on 5/28/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

final class LoadTrackerListOperation: Operation {
    
    private var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override func main() {
        self.isExecuting = true
        self.getPublishedVersion { (publishedVersion) in
            let localVersion = UserPreferences.instance.trackerListVersion()
            if localVersion == 0 || publishedVersion > localVersion || !self.doesTrackerListFileExist() {
                // List is out of date. Update it.
                self.downloadTrackerList(onComplete: { (finished) in
                    if finished {
                        self.isFinished = true
                    }
                    else {
                        //fallback
                        self.moveBugsFromBundleToDisk()
                        self.loadLocalTrackerList()
                        self.isFinished = true
                    }
                })
            }
            else {
                // load local copy
                self.loadLocalTrackerList()
                self.isFinished = true
            }
        }
    }
    
    func getPublishedVersion(completion: @escaping (Int) -> Void) {
        if let url = URL(string: "https://cdn.ghostery.com/update/version") {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil && data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                        if let publishedVersion = json?["bugsVersion"] as? NSNumber {
                            completion(publishedVersion.intValue)
                            return
                        }
                    }

                }
                //catch all the other cases. Keep in mind: There is return above.
                completion(0)
            }).resume()
        }
        else {
            completion(0)
        }
    }
    
    func downloadTrackerList(onComplete: @escaping (Bool) -> ()) {
        // Download tracker list from server.
        if let url = URL(string: "https://cdn.ghostery.com/update/v3/bugs") {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil && data != nil {
                    // save json file to documents directory
                    if let filePath = TrackerList.instance.localTrackerFileURL()?.path {
                        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                    }
                    
                    TrackerList.instance.loadTrackerList(data!)
                    onComplete(true)
                }
                else {
                    NSLog("Tracker list download failed.")
                    //fallback to file in the bundle.
                    onComplete(false)
                }
                
            })
            task.resume()
        }
        else {
            onComplete(false)
        }
    }
    
    func loadLocalTrackerList() {
        if let filePath = TrackerList.instance.localTrackerFileURL()?.path {
            if FileManager.default.fileExists(atPath: filePath) {
                if let data = try? Data.init(contentsOf: URL(fileURLWithPath: filePath)) {
                    TrackerList.instance.loadTrackerList(data)
                }
            }
            else {
                print("File does not exist.")
            }
        }
    }
    
    func doesTrackerListFileExist() -> Bool {
        if let filePath = TrackerList.instance.localTrackerFileURL()?.path {
            if FileManager.default.fileExists(atPath: filePath) {
                return true
            }
        }
        return false
    }
    
    func moveBugsFromBundleToDisk() {
        if let path = Bundle.main.path(forResource: "bugs", ofType: "json") {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data.init(contentsOf: url) {
                if let filePath = TrackerList.instance.localTrackerFileURL()?.path {
                    FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                }
            }
        }
    }
}
