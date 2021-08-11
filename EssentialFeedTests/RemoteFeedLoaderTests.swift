//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nicolas Guasch on 26-07-21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "https://given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach{ index,code in
            
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        client.complete(withStatusCode: code, at: index)
        
        XCTAssertEqual(capturedError, [.invaildData])
        }
        
    }
    
    
   
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!) -> (RemoteFeedLoader,HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL,completion: (Error?,HTTPURLResponse?)->Void)]()
        
        var requestURLs: [URL]{
            return messages.map{$0.url}
        }
     
        func get(from url: URL, completion: @escaping (Error?,HTTPURLResponse?) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(error,nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0){
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)
            messages[index].completion(nil,response)
        }
        
    }

}
