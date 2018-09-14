//
//  LogoLoaderTests.swift
//  AppiumTests
//
//  Created by Mahmoud Adam on 9/14/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import XCTest
@testable import Client

class LogoLoaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDomains() {
        XCTAssertTrue(LogoLoader.domainName("http://abc.go.com") == "go", "domain for http://abc.go.com != go")
        XCTAssertTrue(LogoLoader.domainName("http://m.facebook.com") == "facebook", "domain for http://m.facebook.com != facebook")
        XCTAssertTrue(LogoLoader.domainName("http://direct.gov.uk") == "direct", "domain for http://direct.gov.uk != direct")
        XCTAssertTrue(LogoLoader.domainName("http://images.google.com") == "google", "domain for http://images.google.com != google")
        XCTAssertTrue(LogoLoader.domainName("http://images.google.com.eg") == "google", "domain for http://images.google.com.eg != google")
        XCTAssertTrue(LogoLoader.domainName("http://bbc.co.uk") == "bbc", "domain for http://bbc.co.uk != bbc")
    }
    
    func testFacebookMobileLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://m.facebook.com")
        XCTAssertTrue(logoDetails.hostName == "facebook", "Host name for http://m.facebook.com != facebook")
    }
    
    func testGoogleImagesLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://images.google.com")
        XCTAssertTrue(logoDetails.hostName == "images.google", "Host name for http://images.google.com != images.google")
    }
    
    
    func testAbcGoLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://abc.go.com")
        XCTAssertTrue(logoDetails.hostName == "abc.go", "Host name for http://abc.go.com != abc.go")
    }
    
    func testBbcLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://bbc.co.uk")
        XCTAssertTrue(logoDetails.hostName == "bbc", "Host name for http://bbc.co.uk != bbc")
    }
    
}
