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


@MainActor
public protocol MZWebSerivceProtocol: AnyObject {
    
    typealias ResultRawInfo = MZWeb.ResultRawInfo
    
    associatedtype ParametersType: MZWebSerivceParametersType
    associatedtype ResultType: MZWebSerivceResultType
    
    var name: String { get }
    var serivceDescription: String? { get }
    
    init(_ parameters: ParametersType?)
    
    func beforeRequest() async throws
    func createRequest() -> URLRequest
    
    func request() async throws -> ResultType
    
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
    
    public func request() async throws -> ResultType {
        try await beforeRequest()
        
        let (data, response) = try await URLSession.shared.data(for: createRequest())
        let resultInfo = ResultRawInfo(serviceName: name, data: data, response: response)
        
        if let error = catchError(resultInfo: resultInfo) {
            throw error
        }
        
        return result(of: resultInfo)
    }
    
    public func createRequest() -> URLRequest {
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
