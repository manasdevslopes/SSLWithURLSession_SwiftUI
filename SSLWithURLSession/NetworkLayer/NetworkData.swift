//
// NetworkData.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

// These can be written directly here or can be pulled from Environments. These values can be given by backend guy.
var apiDomain: String = "api.blacenova.com"
var apiToken: String = "3002C487-A5D4-43D4-8D28-D4A3D4A3D4A3"
var apiVersion: String = "v1"

// create a struct for Header Object.
struct Header {
  let name: String
  let content: String
}

// POST - .cardScan, .odometerScan, .changeEmail, .login, .logout
// PUT - .editUser
// DELETE - .deleteFavourite, .deleteUser, .deleteVehicle
// GET - .getVehicles, .getFavourites, .user

// now let's create an enum of all network apis.
enum NetworkData {
  // GET
  case getVehicles
  case getFavourites
  case user
  // POST
  case cardScan
  case odometerScan
  case changeEmail
  case login
  case logout
  // PUT
  case editUser
  // DELETE
  case deleteFavourite
  case deleteUser
  case deleteVehicle
  
  // Let's create a base URL format
  var baseURL: String {
    "https://\(apiDomain)/"
  }
  
  // For Api's other than Login, you must be needed token. So get it from ur helper class
  var token: String {
    // viewModel.shared.user.token ?? "" // For example
    "123FDJH-DADJKHJK-DADJH-DADJH-DADJH"
  }
  
  var fullBaseURL: String {
    baseURL + apiVersion
  }
  
  // Now create endpoints
  func endpoint(with extraURL: String?) -> URLComponents {
    switch self {
      case .getVehicles: return URLComponents(string: fullBaseURL + "/vehicles")!
      // If there is extra URL need to pass then pass it like this
      case .getFavourites: return URLComponents(string: fullBaseURL + "/favorites" + (extraURL ?? ""))!
      case .user: return URLComponents(string: fullBaseURL + "/user")!
      case .cardScan: return URLComponents(string: fullBaseURL + "/scan/card")!
      case .odometerScan: return URLComponents(string: fullBaseURL + "/scan/odometer")!
      case .changeEmail: return URLComponents(string: fullBaseURL + "/user/changeEmail")!
      case .login: return URLComponents(string: fullBaseURL + "/login")!
      case .logout: return URLComponents(string: fullBaseURL + "/logout")!
      case .editUser: return URLComponents(string: fullBaseURL + "/users/user")!
      case .deleteFavourite: return URLComponents(string: fullBaseURL + "/favourites" + (extraURL ?? ""))!
      case .deleteUser: return URLComponents(string: fullBaseURL + "/users/user")!
      case .deleteVehicle: return URLComponents(string: fullBaseURL + "/vehicle")!
    }
  }
  
  // Now Create params
  func parameters(with params: [URLQueryItem]? = nil) -> [URLQueryItem] {
    switch self {
      default: return params ?? []
    }
  }
  
  // Now, create methods for all APIs
  var method: String {
    switch self {
      case .cardScan, .odometerScan, .changeEmail, .login, .logout: return "POST"
      case .editUser: return "PUT"
      case .deleteFavourite, .deleteUser, .deleteVehicle: return "DELETE"
      default: return "GET"
    }
  }
  
  // Now let's create headers
  var headers: [Header] {
    // if there are some headers which are repeating in many APIs, then for that create an generalHeaders
    let generalHeaders = [
      Header(name: "Accept-Encoding", content: "gzip;q=1.0, compress;q=0.5"),
      Header(name: "Accept-Language", content: Locale.current.language.languageCode?.identifier ?? ""),
      Header(name: "Content-Type", content: "application/json"),
      Header(name: "User-Agent", content: userAgent), // according to requirement create userAgent accordingly
      Header(name: "api-token", content: apiToken)
    ]
    switch self {
      case .getVehicles:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .getFavourites:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .cardScan:
        return [
          Header(name: "Content-Type", content: "application/x-www-form-urlencoded"),
          Header(name: "Accept-Language", content: Locale.current.language.languageCode?.identifier ?? ""),
          Header(name: "api-token", content: apiToken),
          Header(name: "User-Agent", content: userAgent) // according to requirement create userAgent accordingly
        ]
      case .odometerScan:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .logout:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .editUser:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .deleteFavourite:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .deleteUser:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
      case .deleteVehicle:
        return token.isEmpty ? generalHeaders : generalHeaders + [Header(name: "Authorization", content: "Bearer \(token)")]
        
      default: return generalHeaders
    }
  }
}
