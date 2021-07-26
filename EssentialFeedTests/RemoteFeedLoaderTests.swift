//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nicolas Guasch on 26-07-21.
//

import XCTest

class RemoteFeedLoader{

    func load(){
        HTTPClient.shared.requestURL = URL(string: "http:algo")
    }
}


class HTTPClient {
    static let shared = HTTPClient()
    private init(){}
    var requestURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestURL)
        
    }

}
