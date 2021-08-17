//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 27-07-21.
//

import Foundation


public final class RemoteFeedLoader{
    
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invaildData
    }
    
    public enum Result: Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result)->Void){
        client.get(from: url){ result in
            switch result{
            case let .success(data, response):
                do{
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                } catch{
                    completion(.failure(.invaildData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
