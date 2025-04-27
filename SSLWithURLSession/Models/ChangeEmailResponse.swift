//
// ChangeEmailResponse.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct ChangeEmailResponse: Codable {
  var userId: String
  var uid: String
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case uid
  }
}
