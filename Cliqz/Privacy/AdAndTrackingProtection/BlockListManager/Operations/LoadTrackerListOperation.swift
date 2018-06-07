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
        if let url = URL(string: "https://cdn.ghostery.com/update/version") {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                            if let publishedVersion = json["bugsVersion"] as? NSNumber {
                                let localVersion = UserPreferences.instance.trackerListVersion()
                                //let localVersion = UserDefaults.standard.integer(forKey: "TrackerListVersion")
                                if publishedVersion.intValue > localVersion {
                                    // List is out of date. Update it.
                                    self.downloadTrackerList(onComplete: {
                                        self.isFinished = true
                                    })
                                }
                                else {
                                    // load local copy
                                    self.loadLocalTrackerList()
                                    self.isFinished = true
                                }
                            }
                            else {
                                self.isFinished = true
                            }
                        }
                        else {
                            self.isFinished = true
                        }
                    }
                    catch {
                        NSLog("Couldn't download tracker list version number.")
                        // load local copy
                        self.loadLocalTrackerList()
                        self.isFinished = true
                    }
                }
                else {
                    // load local copy
                    self.loadLocalTrackerList()
                    self.isFinished = true
                }
            })
            task.resume()
        }
        else {
            self.isFinished = true
        }
    }
    
    func downloadTrackerList(onComplete: @escaping () -> ()) {
        // Download tracker list from server.
        if let url = URL(string: "https://cdn.ghostery.com/update/v3/bugs") {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil && data != nil {
                    // save json file to documents directory
                    if let filePath = TrackerList.instance.localTrackerFileURL()?.path {
                        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                    }
                    
                    TrackerList.instance.loadTrackerList(data!)
                }
                else {
                    NSLog("Tracker list download failed.")
                }
                onComplete()
            })
            task.resume()
        }
        else {
            onComplete()
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
}
