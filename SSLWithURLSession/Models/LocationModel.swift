//
// LocationModel.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct LocationModel: Decodable, Hashable {
  let id: String
  let idCpo: String?
  let operatorID: String?
  let name: String?
  let country: String?
  let city: String?
  let street: String?
  let postalCode: String?
  let houseNum: String?
  let floor: String?
  let region: String?
  let timezone: String?
  let latitude: Double
  let longitude: Double
  let isOpen24_7: Bool?
  let chargingWhenClosed: Bool?
  let source: String?
  let md5Hash: String?
  let lastUpdated: String?
  let userDistance: Double?
  let accessibility: String?
  let facility: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case idCpo = "id_cpo"
    case operatorID = "operator_id"
    case name = "name"
    case country = "country"
    case city = "city"
    case street = "street"
    case postalCode = "postal_code"
    case houseNum = "house_num"
    case floor = "floor"
    case region = "region"
    case timezone = "timezone"
    case latitude = "latitude"
    case longitude = "longitude"
    case isOpen24_7 = "is_open_24_7"
    case chargingWhenClosed = "charging_when_closed"
    case source = "source"
    case md5Hash = "md5_hash"
    case lastUpdated = "last_updated"
    case userDistance = "userDistance"
    case accessibility = "accessibility"
    case facility = "facility"
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
