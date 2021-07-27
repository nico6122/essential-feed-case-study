//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nicolas Guasch on 26-07-21.
//

import XCTest

class RemoteFeedLoader{
    
    let url: URL
    let client: HTTPClient

    init(url: URL,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load(){
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    func get(from: URL) {
        requestURL = from
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let url = URL(string: "https://given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "https://given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestURL, url)
        
    }

}
