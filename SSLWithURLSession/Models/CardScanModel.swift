//
// CardScanModel.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct CardScanModel: Decodable {
  let cardNumber: String?
  
  enum CodingKeys: String, CodingKey {
    case cardNumber
  }
}
