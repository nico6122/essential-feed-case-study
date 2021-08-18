//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 23-07-21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error:Equatable{}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func loadFeed(completion: @escaping (LoadFeedResult<Error>)->Void)
}
