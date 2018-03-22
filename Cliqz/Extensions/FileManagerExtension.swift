//
//  FileManagerExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 3/22/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit

extension FileManager {
    func deleteLocalFile(_ localPath: URL) {
        do {
            if fileExists(atPath: localPath.path) {
                try removeItem(atPath: localPath.path)
            }
        } catch let error as NSError {
            debugPrint("[FileManager] Could not delete local file at path \(localPath) because of the following error \(error)")
        }
    }
}
