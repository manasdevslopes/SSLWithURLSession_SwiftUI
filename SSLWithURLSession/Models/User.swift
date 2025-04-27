//
// User.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct User: Decodable {
  var token: String?
  var firstName: String
  var lastName: String
  let email: String
  
  enum CodingKeys: String, CodingKey {
    case token
    case firstName
    case lastName
    case email
  }
}
