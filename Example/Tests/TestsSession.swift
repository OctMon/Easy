//
//  TestsSession.swift
//  Easy_Tests
//
//  Created by OctMon on 2018/10/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Easy

private let Session: EasySession = {
    var config = EasySessionConfig()
    config.url.global = "https://interface.meiriyiwen.com"
    config.code.success = config.code.unknown
    return EasySession(config)
}()

struct Article: Codable {
    let author, title, digest, content: String?
    let wc: Int?
    let date: DateClass?
}

struct DateClass: Codable {
    let curr, next, prev: String?
}

class TestsSession: XCTestCase {
    
    let path = "article/"
    
    func easyCreateExpectation(description: String = "Request Handler Called") -> XCTestExpectation {
        return expectation(description: description)
    }
    
    func easyWaitForExpectations(timeout: TimeInterval = Session.config.other.timeout + 1, handler: XCWaitCompletionHandler? = nil) {
        waitForExpectations(timeout: timeout, handler: handler)
    }
    
    func easyFulfill(expectation: XCTestExpectation, result: EasyResult) -> String? {
        expectation.fulfill()
        return result.error?.localizedDescription
    }
    
    func getArticle(handler: @escaping (EasyResult, Article?) -> Void) {
        Session.get(path: path + "today", parameters: ["dev": 1]) { (result) in
            handler(result, JSONDecoder().decode(Article.self, from: result.data.toData))
        }
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSession() {
        let expectation = easyCreateExpectation()
        getArticle { (result, article) in
            let fill = self.easyFulfill(expectation: expectation, result: result)
            XCTAssertNil(fill, fill ?? "")
            guard let article = article, result.valid else {
                EasyLog.debug(result.error?.localizedDescription)
                return
            }
            EasyLog.debug(article)
        }
        easyWaitForExpectations()
    }

}
