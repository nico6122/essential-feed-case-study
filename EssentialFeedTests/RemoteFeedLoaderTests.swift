//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nicolas Guasch on 26-07-21.
//

import XCTest

class RemoteFeedLoader{

    func load(){
        HTTPClient.shared.get(from: URL(string: "http:algo")!)
    }
}


class HTTPClient {
    static var shared = HTTPClient()
    func get(from: URL){}
}

class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    override func get(from: URL) {
        requestURL = from
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestURL)
        
    }

}
