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
        XCTAssertTrue(LogoLoader.domainName("http://de-de.facebook.com") == "facebook", "domain for http://de-de.facebook.com != facebook")
        XCTAssertTrue(LogoLoader.domainName("http://direct.gov.uk") == "direct", "domain for http://direct.gov.uk != direct")
        XCTAssertTrue(LogoLoader.domainName("http://images.google.com") == "google", "domain for http://images.google.com != google")
        XCTAssertTrue(LogoLoader.domainName("http://images.google.com.eg") == "google", "domain for http://images.google.com.eg != google")
        XCTAssertTrue(LogoLoader.domainName("http://bbc.co.uk") == "bbc", "domain for http://bbc.co.uk != bbc")
        XCTAssertTrue(LogoLoader.domainName("http://en.wikipedia.org") == "wikipedia", "domain for en.wikipedia.org != wikipedia")
        XCTAssertTrue(LogoLoader.domainName("http://amp.welt.de") == "welt", "domain for http://amp.welt.de != welt")
        XCTAssertTrue(LogoLoader.domainName("https://www.fci.cu.edu.eg") == "cu", "domain for https://www.fci.cu.edu.eg != cu")
    }
    
    func testFacebookMobileLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://m.facebook.com")
        XCTAssertTrue(logoDetails.hostName == "facebook", "Host name for http://m.facebook.com != facebook")
    }
    
    func testFacebookDELogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://de-de.facebook.com")
        XCTAssertTrue(logoDetails.hostName == "facebook", "Host name for http://de-de.facebook.com != facebook")
    }
    
    func testFciLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("https://www.fci.cu.edu.eg")
        XCTAssertTrue(logoDetails.hostName == "cu", "Host name for https://www.fci.cu.edu.eg != cu")
    }
    
    func testDirectGovLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://direct.gov.uk")
        XCTAssertTrue(logoDetails.hostName == "direct", "Host name for http://direct.gov.uk != direct")
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
    
    
    func testAmpWeltLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://amp.welt.de")
        XCTAssertTrue(logoDetails.hostName == "welt", "Host name for http://amp.welt.de != welt")
    }
    
    
    func testWikipediaLogoDetails() {
        let logoDetails = LogoLoader.fetchLogoDetails("http://en.wikipedia.org")
        XCTAssertTrue(logoDetails.hostName == "wikipedia", "Host name for http://en.wikipedia.org != wikipedia")
    }
    
}
