//
//  LogoLoader.swift
//  Client
//
//  Created by Sahakyan on 1/2/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import SnapKit
import SDWebImage
import SwiftyJSON
import KKDomain

struct LogoInfo {
	var url: String?
	var color: String?
	var prefix: String?
	var fontSize: Int?
	var hostName: String?
}

extension String {
	
	func asciiValue() -> Int {
		var s = UInt32(0)
		for ch in self.unicodeScalars {
			if ch.isASCII {
				s += ch.value
			}
		}
		return Int(s)
	}
}

class LogoLoader {
    static var shared = LogoLoader()

    private static let dbVersion = "1537258816173"
    private static let dispatchQueue = DispatchQueue(label: "com.cliqz.logoLoader", attributes: .concurrent);

    private lazy var logoDB: JSON? = {
        if let path = Bundle.main.path(forResource: "logo-database", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) as Data {
            return JSON(jsonData)
        }

        return nil
    }()

    func loadLogo(_ url: String, completionBlock: @escaping (_ image: UIImage?, _ logoInfo: LogoInfo?,  _ error: Error?) -> Void) {
        LogoLoader.dispatchQueue.async {
            let details = self.fetchLogoDetails(url)
            if let u = details.url {
                self.downloadImage(u, completed: { (image, error) in
                    DispatchQueue.main.async {
                        completionBlock(image, details, error)
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completionBlock(nil, details, nil)
                }
            }
        }
    }

    func downloadImage(_ url: String, completed: @escaping (_ image: UIImage?, _ error:  Error?) -> Void) {
        if let u = URL(string: url) {
            SDWebImageManager.shared().loadImage(with: u, options: SDWebImageOptions.highPriority, progress: nil, completed: { (image, _, error, _, _, _) in
                completed(image, error)
            })
        } else {
            completed(nil, nil)
        }
    }

    func fetchLogoDetails(_ url: String) -> LogoInfo {
        var logoDetails = LogoInfo()
        logoDetails.color = nil
        logoDetails.fontSize = 16
        var fixedURL = url
        // TODO: Remove this crazy hack, which is done for localNews. For the next release we should change url parsing lib to https://publicsuffix.org/learn/
        if url.contains("tz.de") {
            fixedURL = "http://tz.de"
        }

        if let domainName = self.domainName(fixedURL), //URLParser.getURLDetails(fixedURL),
            let hostName = URL(string: fixedURL)?.host,
            let db = self.logoDB,
            db != JSON.null,
            db["domains"] != JSON.null {
            let details = db["domains"]
            let host = details[domainName]
            logoDetails.hostName = domainName
            logoDetails.prefix = domainName.subString(to: min(2, domainName.count)).capitalized
            if let list = host.array,
                list.count > 0 {
                let domainRule = generateDomainRule(hostName, domainName)
                for info in list {
                    if info != JSON.null,
                        let r = info["r"].string,
                        domainRule.contains(r) || info == list.last {

                        if let doesLogoExist = info["l"].number, doesLogoExist == 1 {
                            logoDetails.url = "https://cdn.cliqz.com/brands-database/database/\(LogoLoader.dbVersion)/pngs/\(domainName)/\(r)_192.png"
                        }
                        logoDetails.color = info["b"].string
                        if let txt = info["t"].string {
                            logoDetails.prefix = txt
                        }
                        if r != "$", let address = hostName.lastIndex(of: domainName) {
                            logoDetails.hostName = hostName.subString(to: address + domainName.count)
                        }
                        break
                    }
                }
            }
        }
        if logoDetails.color == nil {
            logoDetails.color = "000000"
            let palette = self.logoDB?["palette"]
            if let list = palette?.array,
                let asciiVal = logoDetails.hostName?.asciiValue() {
                let idx = asciiVal % list.count
                logoDetails.color = list[idx].string
            }
        }
        return logoDetails
    }

    func generateDomainRule(_ host: String, _ domain: String) -> String {
        if let address = host.lastIndex(of: domain) {
            let rule = "\(host.subString(to: address))$\(host.subString(from: address + domain.count))"
            return rule
        }
        return "\(domain).$"

    }

    func domainName(_ urlString: String) -> String? {
        if let url = NSURL(string: urlString) {
            var domain: String?
            var suffix: String?
            try? ObjC.catchException { domain = url.host?.registeredDomain() }
            try? ObjC.catchException { suffix = url.publicSuffix() }

            if let domain = domain, let suffix = suffix {
                return domain.subString(to: domain.count - suffix.count - 1)
            }
        }
        return nil
    }
}
