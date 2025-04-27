//
// Vehicle.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct Vehicle: Decodable, Hashable {
  let vehicleID: Int
  let vehicleMake: String
  let vehicleModel: String?
  let vehicleModelVersion: String?
  let drivetrainType: String?
  let drivetrainPower: Int?
  let drivetrainPowerHP: Int?
  let rangeWLTP: Int?
  let chargePlug: String?
  let fastchargePlug: String?
  let batteryCapacityFull: Double?
  let performanceTopspeed: Double?
  let efficiencyWLTPV: Double?
  
  enum CodingKeys: String, CodingKey {
    case vehicleID = "id"
    case vehicleMake
    case vehicleModel
    case vehicleModelVersion
    case drivetrainType
    case drivetrainPower
    case drivetrainPowerHP
    case rangeWLTP
    case chargePlug
    case fastchargePlug
    case batteryCapacityFull
    case performanceTopspeed
    case efficiencyWLTPV
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(vehicleID)
  }
}
