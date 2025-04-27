//
// NetworkHelper.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    
import Foundation
import UIKit

// Generic Decode function
func decode<T: Decodable>(with data: Data) throws -> T {
  return try JSONDecoder().decode(T.self, from: data)
}

// Generic Encode function
func encode<T: Encodable>(with data: T) throws -> Data {
  return try JSONEncoder().encode(data)
}

// Create CustomError Object
struct CustomError: Error {
  var code: String?
  let statusCode: Int
  let error: NetworkError
  var title: String?
  var description: String?
  var token: String?
  var firstName: String?
  var lastName: String?
}

struct ErrorWithTranslation: Decodable {
  var code: Int
  var title: String
  var description: String
}

enum NetworkError: Error {
  case encode(String)
  case decode(String)
  case response(String)
  case statusCode(String)
  case none
  
  var message: Any {
    switch self {
      case .encode(let error), .decode(let error), .response(let error), .statusCode(let error):
        return error
      default: return "Something went wrong"
    }
  }
}

extension NetworkData {
  // When Encoding and Decoding needs to be done
  func getDataSync<T: Decodable, Q: Encodable>(body: Q, parameters: [URLQueryItem]? = nil, isJson: Bool = true, extraURL: String? = nil) async -> Result<T?, CustomError> {
    var request = getRequest(with: parameters, and: extraURL)
    do {
      request.httpBody = try encode(with: body)
    } catch {
      return .failure(CustomError(statusCode: 500, error: NetworkError.encode(error.localizedDescription)))
    }
    return await doRequest(with: request, isJson: isJson, specialDecoding: true)
  }
  
  func getDataSync<T: Decodable>(parameters: [URLQueryItem]? = nil, isJson: Bool = true, extraURL: String? = nil, fetchUserToken: String? = nil) async -> Result<T?, CustomError> {
    // Only for .user endpoint
    return await doRequest(with: getRequest(with: parameters, and: extraURL, fetchUserToken: fetchUserToken), isJson: isJson)
  }
  
  func getDataSync<T: Decodable>(image: Data, parameters: [URLQueryItem]? = nil, extraURL: String? = nil) async -> Result<T?, CustomError> {
    var request = getRequest(with: parameters, and: extraURL)
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    let httpBody = NSMutableData()
    httpBody.append(convertFileData(fieldName: "file", fileName: "imagename.jpeg", mimeType: "image/jpeg", fileData: image, using: boundary))
    httpBody.appendString("--\(boundary)--")
    
    request.httpBody = httpBody as Data
    
    return await doRequest(with: request)
  }
  
  // Create a Request method -
  private func getRequest(with parameters: [URLQueryItem]? = nil, and extraURL: String? = nil, fetchUserToken: String? = nil) -> URLRequest {
    var url = endpoint(with: extraURL)
    let finalParameters = self.parameters(with: parameters)
    if !finalParameters.isEmpty { url.queryItems = finalParameters }
    var request = URLRequest(url: url.url!, cachePolicy: .reloadIgnoringLocalCacheData) // if u want to add timeoutInterval, then add it here in URLRequest as a third parameter.
    
    // NOTE: - If there is any change in the urlString, then edit it here and create a new URLRequest for that API
    // Otherwise leave it
    
    for header in self.headers {
      request.setValue(header.content, forHTTPHeaderField: header.name)
    }
    if self == .user, let fetchUserToken {
      request.setValue("Bearer \(fetchUserToken)", forHTTPHeaderField: "Authorization")
    }
    request.httpMethod = method
    
    return request
  }
  
  // After requet method, create a doRequest method to decode with the request created above
  private func doRequest<T: Decodable>(with request: URLRequest, isJson: Bool = true, specialDecoding: Bool = false) async -> Result<T?, CustomError> {
    showDebugCurl(for: request)
    
    do {
      let session = URLSession(configuration: URLSessionConfiguration.default, delegate: AuthenticationDelegate.shared, delegateQueue: nil)
      let (data, urlResponse) = try await session.data(for: request)
      
      showDebugResponse(urlResponse) // To see the responses for network calls
      showDebugDataResponse(data) // To see the data received for network calls
      
      guard let response = urlResponse as? HTTPURLResponse else {
        return Result.failure(CustomError(statusCode: 500, error: NetworkError.response("Request response its not an HTTPSURLResponse")))
      }
      
      // if you want to return interceptCustomBehaviourResponseResult, can do it here. Otherwise move on to next step.
      
      // All three below can differ and totally depend on ur requirements + response form backend.
      if response.statusCode == 500 && specialDecoding {
        let errorInfo: ErrorWithTranslation = try decode(with: data)
        
        return .failure(
          CustomError(
            code: String(errorInfo.code),
            statusCode: 500,
            error: NetworkError.response("Request failed, translations are provided by backend"),
            title: errorInfo.title,
            description: errorInfo.description
          )
        )
      }
      // if you want to do something on specific statuscode, then
      if response.statusCode == 206 {
        let responseData = String(decoding: data, as: UTF8.self)
        let parsedData = responseData.toJSON() as? [String : AnyObject]
        
        return .failure(
          CustomError(
            code: "40027",
            statusCode: response.statusCode,
            error: NetworkError.response("Request failed, translations are provided by backend"),
            token: parsedData?["token"] as? String,
            firstName: parsedData?["firstName"] as? String,
            lastName: parsedData?["lastName"] as? String
          )
        )
      }
      // Also check, if it is doesn't fit in this codes
      if !(200...299).contains(response.statusCode) {
        let responseData = String(decoding: data, as: UTF8.self)
        let parsedData = responseData.toJSON() as? [String : AnyObject]
        return .failure(
          CustomError(
            code: parsedData?["code"] as? String ?? "100",
            statusCode: response.statusCode,
            error: NetworkError.response("Error statusCode \(response.statusCode)")
          )
        )
      }
      
      do {
        let result: T? = isJson ? try decode(with: data) : data as? T
        return .success(result)
      } catch let error {
        return .failure(CustomError(statusCode: response.statusCode, error: NetworkError.decode(error.localizedDescription)))
      }
    } catch let error {
      switch (error as? URLError)?.code {
        case .some(.clientCertificateRequired):
          if self == .login { // or any API (mostly inital APIs)
            return Result.failure(
              CustomError(statusCode: 403, error: NetworkError.response(error.localizedDescription))
            )
          }
        default: break
      }
      return Result.failure(CustomError(statusCode: 500, error: NetworkError.response(error.localizedDescription)))
    }
  }
  
  var userAgent: String {
    if let info = Bundle.main.infoDictionary {
      let appVersion = info["CFBundleShortVersioningString"] as? String ?? "Unknown"
      
      let osNameVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        
        let osName: String = {
          #if os(iOS)
          return "iOS"
          #elseif os(watchOS)
          return "watchOS"
          #elseif os(tvOS)
          return "tvOS"
          #elseif os(macOS)
          return "OS X"
          #elseif os(Linux)
          return "Linux"
          #else
          return "Unknown"
          #endif
        }()
        
        return "\(osName)/\(versionString)"
      }()
      
      let brand = "blacenova"
      
      var result = "\(osNameVersion)/\(UIDevice.modelName)/(\(brand)/\(appVersion)"
      return result
    }
    return ""
  }
}

// MARK: - Helper Function for Debug
extension NetworkData {
  // To show cURL
  private func showDebugCurl(for request: URLRequest) {
    #if DEBUG
    print("\(String(repeating: "-", count: 100))\n[\(getUtcTimeString())]\nNetworkRequest cURL:\n\(request.cURL(pretty: true))")
    #endif
  }
  
  private func showDebugResponse(_ response: URLResponse) {
    #if DEBUG
      print("\(String(repeating: "-", count: 100))\n[\(getUtcTimeString())]\nNetworkResponse: \(response)")
    #endif
  }
  
  private func showDebugDataResponse(_ data: Data) {
    #if DEBUG
      print("\(String(repeating: "-", count: 100))\nNetworkDataResponse: \(String(decoding: data, as: UTF8.self))\n")
    #endif
  }
  
  private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
    let data = NSMutableData()
    // It depends on what type of data required in BE.
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.append(fileData)
    data.appendString("\r\n")
    
    return data as Data
  }
}

extension URLRequest {
  public func cURL(pretty: Bool = false) -> String {
    let newLine = pretty ? "\\\n" : ""
    let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
    let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
    
    var cURL = "curl "
    var header = ""
    var data: String = ""
    
    if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
      for (key, value) in httpHeaders {
        header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
      }
    }
    
    if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8), !bodyString.isEmpty {
      data = "--data '\(bodyString)'"
    }
    
    cURL += method + url + header + data
    
    return cURL
  }
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

func getUtcTimeString(_ date: Date? = nil) -> String {
  let date = date ?? Date()
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  formatter.timeZone = TimeZone(abbreviation: "UTC")
  let utcTimeZoneStr = formatter.string(from: date)
  return utcTimeZoneStr
}

extension String {
  func toJSON() -> Any? {
    guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
    return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
  }
}
