//
//  MZWeb.swift
//  MZWeb
//
//  Created by Mizuki Inaba on 2022/6/4.
//

import Foundation
import Combine
import MZSwifts


public class MZWeb {
    
    static public let shared: MZWeb = .init()
    
    
    public var apiURL: URL!
    public var isEnableLog: Bool { true }
    public var commonConfigActionToRequest: ((inout URLRequest, any MZWebSerivceProtocol) -> ())? = nil
    
    internal func commonConfigToRequest(_ request: inout URLRequest,
                                        for service: any MZWebSerivceProtocol) {
        commonConfigActionToRequest?(&request, service)
    }
    
    // MARK: Private
    
    private var __tasks: [AnyCancellable] = []
    
    private init() { }
}


extension MZWeb {
    
    public struct CommonPublishers {
                
        public static func success() -> AnyPublisher<(), Error> {
            Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        public static func fail(_ error: Error) -> AnyPublisher<(), Error> {
            Fail(error: error).eraseToAnyPublisher()
        }
        
        public static func catchEmailError(email: String) -> AnyPublisher<(), Error> {
//            if let error = MZWebError.catchEmail(email: email) {
//                return fail(error)
//            }
            
            return success()
        }
        
        
        // MARK: Private
        
        private init() { }
    }
}


extension MZWeb {
    
    public enum HttpMethod: String {
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
    }
}
    

// MARK: ResultRawInfo
extension MZWeb {
    
    public struct ResultRawInfo {
        
        public var serviceName: String
        public var data: Data
        public var response: URLResponse
        
        public var errorMessage: String? {
            guard let json = data.utf8String,
                  let dict = MZJson.dictionary(from: json)
            else {
                if let messageFromJson = data.utf8String {
                    return messageFromJson
                }
                
                return nil
            }
            
            let codeText = {
                guard let code = dict["code"] else { return "" }
                guard let codeInt = code as? Int else { return "" }
                
                if codeInt == 0 { return "" }
                
                return "(\(codeInt))"
            }()
            
            let message = dict["message"] as? String ?? ""
            
            return "\(message)\(codeText)"
        }
        
        public var message: String? { errorMessage }
        
        public func tryDictionary() -> [String: AnyObject]? {
            guard let json = data.utf8String else { return nil }
            
            return MZJson.dictionary(from: json)
        }
        
        public func logErrorMessageIfNeed() {
            guard let message = errorMessage else { return }
            
            if message.lowercased() == "Success".lowercased() {
                MZDebug.log("😼 errorMessage: \(message)")
            } else {
                MZDebug.log("🙀 errorMessage: \(message)")
            }
        }
        
        public func errorMessageCompare(to message: String) -> Bool {
            guard let errorMessage = errorMessage else { return false }
            
            return errorMessage.lowercased() == message.lowercased()
        }
    }
}


// MARK: Support
extension MZWeb {
    
    public struct Support {
        
        public static func httpBodyData(from dictionary: [String: Any]) -> Data? {
            let dict: [String: AnyObject] = dictionary.reduce(into: [:]) { result, keyValue in
                result[keyValue.key] = keyValue.value as AnyObject
            }
            
            let json = MZJson.jsonString(from: dict)
            
            return json?.data(using: .utf8)
        }
        
        
        public static func dictionary(fromResult resultData: Data) -> [String: AnyObject]? {
            guard let json = String(data: resultData, encoding: .utf8)
            else { return nil }
            
            return MZJson.dictionary(from: json)
        }
        
        
        // MARK: Private
        
        private init() { }
    }
    
    internal class func log(_ message: String?, forServiceName name: String) {
        guard MZWeb.shared.isEnableLog else { return }
        guard let message = message else { return }
        
        MZDebug.log("\(name): \(message)")
    }
    
    internal class func log(error: Error) {
        guard MZWeb.shared.isEnableLog else { return }
        
        MZDebug.log("Error: \(error.localizedDescription)")
    }
    
    internal class func log(for request: URLRequest, serviceName: String) {
        guard MZWeb.shared.isEnableLog else { return }
        
        let headersText = request.allHTTPHeaderFields?.map {
            "\($0.key): \($0.value)"
        }.joined(separator: ", ") ?? ""
        
        let bodiesText: String = request.httpBody?.utf8String ?? ""
        
        MZDebug.log(
            """
            Request for '\(serviceName)' {
                method: \(request.httpMethod ?? "<unknown>"),
                url: \(request.url?.absoluteString ?? "<unknown>"),
                header: { \(headersText) }
                body: \(bodiesText)
            }
            """
        )
    }
}
