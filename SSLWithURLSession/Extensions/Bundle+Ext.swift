//
// Bundle+Ext.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

extension Bundle {
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
  
  var releaseVersionNumberPretty: String {
    return "\(releaseVersionNumber ?? "1.0.0")"
  }
  
  var buildVersionNumberPretty: String {
    return "\(buildVersionNumber ?? "1")"
  }
}
