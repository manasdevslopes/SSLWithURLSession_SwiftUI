//
// SomeViewModel.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 03/05/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

// Then in respective ViewModels -
// Use it like this, for example -
class SomeViewModel: ObservableObject {
  @Published var someValue: String?
  @Published var showLoadingToast: Bool = false
  @Published var loadingVehicles: Bool = false
  typealias MakerList = [String: [Vehicle]]
  @Published var makers: MakerList = [:]
  
  private var repository: RepositoryProtocol
  
  init(_ repository: RepositoryProtocol) {
    self.repository = repository
  }
  
  @MainActor
  private func processCapturedImage(_ imageData: Data) {
    Task {
      showLoadingToast = true
      defer { showLoadingToast = false }
      
      switch await repository.cardScan(image: imageData) {
        case .success(let response):
          self.someValue = response?.cardNumber
        case .failure(let error):
          self.someValue = error.code == "500" ? nil : "406"
      }
    }
  }
  
  func fetchVehicles() {
    Task { await getVehicles() }
  }
  @MainActor
  func getVehicles() async {
    self.loadingVehicles = true
    defer { loadingVehicles = false }
    
    var makers: MakerList = [:]
    let fetchedVehicles = await repository.getVehicles()
    for vehicle in fetchedVehicles {
      if makers[vehicle.vehicleMake] == nil {
        makers[vehicle.vehicleMake] = []
      }
      makers[vehicle.vehicleMake]?.append(vehicle)
    }
    
    self.makers = makers
  }
}
