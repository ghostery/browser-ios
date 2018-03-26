//
//  PersistentSet.swift
//  Client
//
//  Created by Tim Palade on 3/23/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

class PersistentSet<A> where A: Hashable {
    
    let id: String
    private var internalSet: Set<A> = Set<A>()
    private weak var userDefaults: UserDefaults? = UserDefaults.standard
    
    init(id: String) {
        self.id = id
        if let diskSet = setFromDisk() {
            self.internalSet = diskSet
        }
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func add(member: A) {
        internalSet.insert(member)
    }
    
    func remove(member: A) {
        internalSet.remove(member)
    }
    
    func removeAll() {
        internalSet = Set()
        save()
    }
    
    func contains(member: A) -> Bool {
        return internalSet.contains(member)
    }
    
    func all() -> [A] {
        return Array(internalSet)
    }
    
    func map<B>(f: (A) -> B) -> [B] {
        return internalSet.map({ (value) -> B in
            return f(value)
        })
    }
    
    private func setFromDisk() -> Set<A>? {
        if let save_dict = userDefaults?.value(forKey: id) as? [String: Any], let array = save_dict["array"] as? [A] {
            return Set.init(array)
        }
        
        return nil
    }
    
    @objc private func save() {
        let save_dict = ["array": Array(self.internalSet)]
        UserDefaults.standard.set(save_dict, forKey: id)
        UserDefaults.standard.synchronize()
    }
}
