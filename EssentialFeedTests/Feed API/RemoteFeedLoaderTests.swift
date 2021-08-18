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
                
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach{ index,code in
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invaildData), when: {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code,data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidadJSON(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invaildData), when:{
            let invalidJSON = Data(_: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageUrl: URL(string: "http://url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "http://other-url.com")!)
    
        let items = [item1.model,item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemJSON([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
        
    }

    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load{ capturedResult.append($0)}
        
        sut = nil
        let json = makeItemJSON([])
        client.complete(withStatusCode: 200, data: json)
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
   
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader,HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file, line)
        trackForMemoryLeaks(client, file, line)
        
        return (sut,client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject,_ file: StaticString = #filePath,_ line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated. Potencial memory leak.",file: file, line: line)
        }
    }
    
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL ) -> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].reduce(into: [String:Any]()){ (accumulated, element) in
            if let value = element.value {
                accumulated[element.key] = value
            }
        }
        return (item,json)
    }
    
    private func makeItemJSON(_ items: [[String:Any]]) -> Data{
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult,expectedResult){
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file:file, line:line)

            default:
                XCTFail("Expect result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
            
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL,completion: (HTTPClientResult)->Void)]()
        
        var requestURLs: [URL]{
            return messages.map{$0.url}
        }
     
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0){
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
    }

}
