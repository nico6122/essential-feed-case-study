//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Nicolas Guasch on 19-08-21.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL){
        session.dataTask(with: url) { (_, _, _) in
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL(){
        //setup
        let url = URL(string: "http://url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        //when
        sut.get(from: url)
        
        //expectation
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask){
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {            
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    
    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask{
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
