/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Alamofire
import Foundation
import Shared
import SwiftyJSON

let SearchSuggestClientErrorDomain = "org.mozilla.firefox.SearchSuggestClient"
let SearchSuggestClientErrorInvalidEngine = 0
let SearchSuggestClientErrorInvalidResponse = 1

/*
 * Clients of SearchSuggestionClient should retain the object during the
 * lifetime of the search suggestion query, as requests are canceled during destruction.
 *
 * Query callbacks that must run even if they are cancelled should wrap their contents in `withExtendendLifetime`.
 */
class SearchSuggestClient {
    fileprivate let searchEngine: OpenSearchEngine
    fileprivate weak var request: Request?
    fileprivate let userAgent: String

    lazy fileprivate var alamofire: SessionManager = {
        let configuration = URLSessionConfiguration.ephemeral
        var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["User-Agent"] = self.userAgent
        configuration.httpAdditionalHeaders = defaultHeaders
        return SessionManager(configuration: configuration)
    }()

    init(searchEngine: OpenSearchEngine, userAgent: String) {
        self.searchEngine = searchEngine
        self.userAgent = userAgent
    }

    func query(_ query: String, callback: @escaping (_ response: [String]?, _ error: NSError?) -> Void) {
        let url = searchEngine.suggestURLForQuery(query)
        if url == nil {
            let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidEngine, userInfo: nil)
            callback(nil, error)
            return
        }

        request = alamofire.request(url!)
            .validate(statusCode: 200..<300)
            // Cliqz
            // The changes below are made for https://cliqztix.atlassian.net/browse/IP-474
            // The original firefox codebase solves this in a different way that we're not able to backport just for this function
            // but once we rebase onto a version of the firefox mobile codebase older than June 12, we can remove these customizations.
            .responseData { dataResponse in
                guard let data = dataResponse.data else {
                    let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                    callback(nil, error)
                    return
                }

                // Check if we got any data at all
                guard data.count > 0 else {
                    callback(nil, nil)
                    return
                }

                // The response will be of the following format:
                //    ["foobar",["foobar","foobar2000 mac","foobar skins",...]]
                // That is, an array of at least two elements: the search term and an array of suggestions.

                // Cliqz
                // Some result suggestion providers (mainly google) return ASCII formatted JSON instead of UTF-8 formatted JSON
                // Try decoding the data as UTF-8 JSON first, since that's the JSON spec
                let jsonUTF8 = JSON(data)
                if let array = jsonUTF8.arrayObject, array.count > 1, let suggestions = array[1] as? [String] {
                    callback(suggestions, nil)
                    return
                }

                // Cliqz
                // If that fails, try ASCII
                if let jsonAsCIIString = String(data: data, encoding: .ascii), let array = JSON(parseJSON: jsonAsCIIString).arrayObject, array.count > 1, let suggestions = array[1] as? [String] {
                    callback(suggestions, nil)
                    return
                }

                // Cliqz
                // If both decoding mechanisms failed, return an error
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error)
            }
    }

    func cancelPendingRequest() {
        request?.cancel()
    }
}
