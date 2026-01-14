//
//  MZWebService.swift
//  MZWeb
//
//  Created by Mizuki Inaba on 2023/4/17.
//

import Foundation
import Combine


public protocol MZWebSerivceParametersType { }
public protocol MZWebSerivceResultType { }

public typealias URLSessionDataTaskPublisher = AnyPublisher<URLSession.DataTaskPublisher.Output,
                                                            URLSession.DataTaskPublisher.Failure>

@MainActor
public protocol MZWebSerivceProtocol: AnyObject {
    
    typealias ResultRawInfo = MZWeb.ResultRawInfo
    typealias MZWebPublisher = AnyPublisher<ResultType, Error>
    
    associatedtype ParametersType: MZWebSerivceParametersType
    associatedtype ResultType: MZWebSerivceResultType
    
    var name: String { get }
    var serivceDescription: String? { get }
    
    init(_ parameters: ParametersType?)

    func startRequest() -> MZWebPublisher
    
    func beforeRequest() -> AnyPublisher<(), Error>
    func urlRequestPubliser() -> URLSessionDataTaskPublisher
    func serivceResultPubliser(resultInfo: ResultRawInfo) -> MZWebPublisher
    
    // # functions for urlRequestPubliser
    func request() -> URLRequest
    func apiSubURLString() -> String
    func httpMethod() -> MZWeb.HttpMethod
    func httpBody() -> Data?
    func moreConfigToRequest(_ request: inout URLRequest)
    
    // # functions for serivceResultPubliser
    func catchError(resultInfo: ResultRawInfo) -> Error?
    func result(of resultInfo: ResultRawInfo) -> ResultType
}


extension MZWebSerivceProtocol {
    
    public var serivceDescription: String? { nil }
    
    public func startRequest() -> MZWebPublisher {
        MZWeb.log(serivceDescription, forServiceName: name)
        
        return beforeRequest()
            .flatMap { () -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> in
                self.urlRequestPubliser()
                    .mapError { $0 }
                    .eraseToAnyPublisher()
            }
            .flatMap { data, response -> MZWebPublisher in
                let resultInfo = ResultRawInfo(serviceName: self.name,
                                               data: data,
                                               response: response)
                
                MZWeb.log(resultInfo.message, forServiceName: resultInfo.serviceName)
                
                return self.serivceResultPubliser(resultInfo: resultInfo)
            }
            .eraseToAnyPublisher()
    }
    
    public func urlRequestPubliser() -> URLSessionDataTaskPublisher {
        URLSession.shared.dataTaskPublisher(for: request()).eraseToAnyPublisher()
    }
    
    public func serivceResultPubliser(resultInfo: ResultRawInfo) -> MZWebPublisher {
//        if let error = Error.catchCommon(for: resultInfo) {
//            return Fail(error: error).eraseToAnyPublisher()
//        }
        
        if let error = catchError(resultInfo: resultInfo) {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(result(of: resultInfo))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func request() -> URLRequest {
        let apiURL = URLComponents(string: "\(MZWeb.shared.apiURL!)\(apiSubURLString())")!.url!
        var request = URLRequest(url: apiURL)
        
        request.httpMethod = httpMethod().rawValue
        request.httpBody = httpBody()
        
        MZWeb.shared.commonConfigToRequest(&request, for: self)
        moreConfigToRequest(&request)
        
        MZWeb.log(for: request, serviceName: self.name)
        
        return request
    }
    
    public func moreConfigToRequest(_ request: inout URLRequest) { }
}


extension MZWebSerivceProtocol {
    
    public func request() async throws -> ResultType {
        try await startRequest().values.first { _ in true }!
    }
}
