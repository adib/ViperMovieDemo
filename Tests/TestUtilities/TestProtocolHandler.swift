//
//  TestProtocolHandler.swift
//  NestedCollectionViewDemoTests
//
//  Created by Sasmito Adibowo on 12/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation


public class LocalResourcesTestProtocolHandler: URLProtocol {
    
    public enum ErrorCode: Int {
        case noError
        case missingTask
        case missingURL
        case incompliantURL
    }

    public static let ErrorDomain = "com.basilsalad.LocalResourcesTestProtocolHandler.ErrorDomain"

    static var resourceMappings = [TestURLResourceKey:TestURLResourceValue]()
    
    static let classLockQueue = DispatchQueue(label:"LocalResourcesTestProtocolHandler-classLockQueue")

    let delegateQueue = DispatchQueue(label: "LocalResourcesTestProtocolHandler-delegate")
    
    let processingQueue = DispatchQueue(label: "LocalResourcesTestProtocolHandler-processing")
    
    let httpVersion = "HTTP/1.1"

    var _task: URLSessionTask?
    
    override public class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else {
            return false
        }
        guard let url = request.url else {
            return false
        }
        guard let key = TestURLResourceKey(url: url) else {
            return false
        }
        return classLockQueue.sync {
            resourceMappings[key] != nil
        }
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    public init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: task.originalRequest!, cachedResponse: cachedResponse, client: client)
        _task = task
    }
    
    override public var task: URLSessionTask? {
        get {
            _task
        }
    }

    override public func startLoading() {
        guard let client = self.client else {
            return
        }
        func returnError(code: ErrorCode) {
            let error = NSError(code: code)
            self.delegateQueue.async {
                client.urlProtocol(self, didFailWithError: error)
            }
        }
        processingQueue.async {
            guard let task = self.task else {
                returnError(code: .missingTask)
                return
            }
            guard let requestURL = task.currentRequest?.url else {
                returnError(code: .missingURL)
                return
            }
            guard let key = TestURLResourceKey(url: requestURL) else {
                returnError(code: .incompliantURL)
                return
            }
            
            guard let mapped = type(of: self).classLockQueue.sync(execute:{
                type(of: self).resourceMappings[key]
            }) else {
                let errorResponse = HTTPURLResponse(url: requestURL, statusCode: 404, httpVersion: self.httpVersion, headerFields: nil)!
                let emptyData = Data()
                self.delegateQueue.async {
                    client.urlProtocol(self, didReceive: errorResponse, cacheStoragePolicy: .notAllowed)
                    client.urlProtocol(self, didLoad: emptyData)
                    client.urlProtocolDidFinishLoading(self)
                }
                return
            }
            do {
                let data = try Data(contentsOf: mapped.file, options: .mappedIfSafe)
                let headerFields = [
                    "Content-Type": mapped.mimeType
                ]
                let successResponse = HTTPURLResponse(url: requestURL, statusCode: 200, httpVersion: self.httpVersion, headerFields: headerFields)!
                self.delegateQueue.async {
                    client.urlProtocol(self, didReceive: successResponse, cacheStoragePolicy: .allowedInMemoryOnly)
                    client.urlProtocol(self, didLoad: data)
                    client.urlProtocolDidFinishLoading(self)
                }
            } catch {
                let headerFields = [
                    "Content-Type": "text/plain"
                ]
                let errorResponse = HTTPURLResponse(url: requestURL, statusCode: 404, httpVersion: self.httpVersion, headerFields: headerFields)!
                self.delegateQueue.async {
                    client.urlProtocol(self, didReceive: errorResponse, cacheStoragePolicy: .notAllowed)
                }
                let body = "Error: \(error)\n"
                if let responseData = body.data(using: .utf8) {
                    self.delegateQueue.async {
                        client.urlProtocol(self, didLoad: responseData)
                    }
                }
                self.delegateQueue.async {
                    client.urlProtocolDidFinishLoading(self)
                }
            }
        }
    }
    
    override public func stopLoading() {
        // empty for now
    }
    
    public class func register(url: URL, returning: URL, mimeType: String) {
        guard let key = TestURLResourceKey(url: url) else {
            return
        }
        let entry = TestURLResourceValue(file: returning, mimeType: mimeType)
        
        classLockQueue.sync {
            resourceMappings[key] = entry
        }
    }
    
    public class func unregister(url: URL) {
        guard let key = TestURLResourceKey(url: url) else {
            return
        }
        classLockQueue.sync {
            _ = resourceMappings.removeValue(forKey: key)
        }
    }
}


struct TestURLResourceKey: Equatable, Hashable {
    var scheme: String
    var host: String
    var path: String
    
    init?(url: URL) {
        guard let scheme = url.scheme else {
            return nil
        }
        guard let host = url.host else {
            return nil
        }
        self.scheme = scheme
        self.host = host
        self.path = url.path
    }
}

struct TestURLResourceValue {
    var file: URL
    var mimeType: String
}

extension NSError {
    convenience init(code: LocalResourcesTestProtocolHandler.ErrorCode, userInfo: [String : Any]? = nil) {
        self.init(domain: LocalResourcesTestProtocolHandler.ErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
