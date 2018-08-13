//
//  LocaleConstants.swift
//  Client
//
//  Created by Khaled Tantawy on 14.02.18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

@objc(LocaleConstants)
class LocaleConstants: NSObject {

    @objc
    func constantsToExport() -> [String: Any]! {
        return ["lang": Locale.current.languageCode ?? "en"]
    }

}
