//
// Certificate.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 12/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation



public class PKCS12 {
  var label: String?
  var keyID: Data?
  var trust: SecTrust?
  var certChain: [SecTrust]?
  var identity: SecIdentity?
  
  let securityError: OSStatus
  
  public init(data: Data, password: String) {
    var items: CFArray?
    let certOptions: NSDictionary = [kSecImportExportPassphrase as NSString: password as NSString]
    
    self.securityError = SecPKCS12Import(data as NSData, certOptions, &items)
    
    if securityError == errSecSuccess {
      let certItems: Array = (items! as Array)
      let dict: [String: AnyObject] = certItems.first! as! [String: AnyObject]
      
      self.label = dict[kSecImportItemLabel as String] as? String
      self.keyID = dict[kSecImportItemKeyID as String] as? Data
      self.trust = dict[kSecImportItemTrust as String] as! SecTrust?
      self.certChain = dict[kSecImportItemCertChain as String] as? [SecTrust]
      self.identity = dict[kSecImportItemIdentity as String] as! SecIdentity?
    }
  }
  
  public convenience init(mainBundleResource: String, resourceType: String, password: String) {
    self.init(data: NSData(contentsOfFile: Bundle.main.path(forResource: mainBundleResource, ofType: resourceType)!)! as Data, password: password)
  }
  
  public func urlCredential() -> URLCredential {
    return URLCredential(
      identity: self.identity!,
      certificates: self.certChain!,
      persistence: URLCredential.Persistence.forSession)
  }
}
