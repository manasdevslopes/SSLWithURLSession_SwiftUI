//
// OdometerScanModel.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct OdometerScanModel: Decodable {
  let result: Int
  
  enum CodingKeys: String, CodingKey {
    case result
  }
}
