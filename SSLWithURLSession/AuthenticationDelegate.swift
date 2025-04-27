//
// AuthenticationDelegate.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 12/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    
import UIKit
import Foundation

class AuthenticationDelegate: NSObject, URLSessionTaskDelegate {
  static let shared = AuthenticationDelegate()
  
  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didReceive challenge: URLAuthenticationChallenge
  ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    
    let cert = PKCS12.init(mainBundleResource: "client-cert", resourceType: "pfx", password: "P8qX#4D52t@!G30")
    return (
      .useCredential,
      URLCredential(
        identity: cert.identity!,
        certificates: cert.certChain!,
        persistence: URLCredential.Persistence.forSession)
    )
  }
}
