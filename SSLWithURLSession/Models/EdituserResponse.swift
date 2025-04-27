//
// EdituserResponse.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct EdituserResponse: Decodable {
  let state: String
  let error: MessageWithCode?
  
  enum CodingKeys: String, CodingKey {
    case state
    case error
  }
}

struct MessageWithCode: Decodable {
  let code: Int
  let message: String
  
  enum CodingKeys: String, CodingKey {
    case code
    case message
  }
}
