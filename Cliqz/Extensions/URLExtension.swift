//
//  URLExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 3/22/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit

extension URL {

    func isYoutubeURL() -> Bool {
        let pattern = "https?://(m\\.|www\\.)?youtube.+/watch\\?v=.*"
        return self.absoluteString.range(of: pattern, options: .regularExpression) != nil
    }
}
