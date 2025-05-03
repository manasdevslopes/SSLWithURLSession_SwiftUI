//
// Repository.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
import SwiftUI
import MapKit
import Foundation

protocol RepositoryProtocol {
  func cardScan(image: Data) async -> Result<CardScanModel?, CustomError>
  func odometerScan(image: Data) async -> Result<OdometerScanModel?, CustomError>
  func changeEmail(email: String, newEmail: String, uid: String?) async -> Bool
  func login(username: String, password: String) async -> Result<User?, CustomError>
  func logout() async -> Bool
  func editUser(name: String, surname: String) async -> Result<EdituserResponse?, CustomError>
  func deleteFavourite(locationId: String) async -> Bool
  func deleteUser() async -> Result<EdituserResponse?, CustomError>
  func deleteVehicle() async -> Bool
  func getVehicles() async -> [Vehicle]
  func getFavourites(userLocation: CLLocationCoordinate2D) async -> [LocationModel]
  func user(username: String, password: String) async -> Result<User?, CustomError>
  func user(token: String) async -> Result<User?, CustomError>
}

struct Repository {
  func cardScan(image: Data) async -> Result<CardScanModel?, CustomError> {
    return await NetworkData.cardScan.getDataSync(image: image)
  }
  
  func odometerScan(image: Data) async -> Result<OdometerScanModel?, CustomError> {
    return await NetworkData.odometerScan.getDataSync(image: image)
  }
  
  func changeEmail(email: String, newEmail: String, uid: String? = nil) async -> Bool {
    let requestBody = UserRequestBody(new_email: newEmail, provider: "blacenova", email: email)
    switch await NetworkData.changeEmail.getDataSync(body: requestBody) as Result<ChangeEmailResponse?, CustomError> {
      case .success(_):
        return true
      case .failure(let error):
        if error.statusCode == 200 || error.code == "200" { return true }
        return false
    }
  }
  
  func login(username: String, password: String) async -> Result<User?, CustomError> {
    let userRequestBody = UserRequestBody(
      provider: "blacenova", username: username,
      password: password,
      app_version: Bundle.main.releaseVersionNumberPretty
    )
    return await NetworkData.login.getDataSync(body: userRequestBody)
  }
  
  func logout() async -> Bool {
    switch await NetworkData.logout.getDataSync(isJson: false) as Result<Bool?, CustomError> {
      case .success: return true
      case .failure: return false
    }
  }
  
  func editUser(name: String, surname: String) async -> Result<EdituserResponse?, CustomError> {
    let userRequestBody = UserRequestBody(
      firstName: name,
      lastName: surname
    )
    return await NetworkData.editUser.getDataSync(body: userRequestBody, isJson: false)
  }
  
  func deleteFavourite(locationId: String) async -> Bool {
    switch await NetworkData.deleteFavourite.getDataSync(isJson: false, extraURL: "/\(locationId)") as Result<Bool?, CustomError> {
      case .success: return true
      case .failure: return false
    }
  }
  
  func deleteUser() async -> Result<EdituserResponse?, CustomError> {
    return await NetworkData.deleteUser.getDataSync()
  }
  
  func deleteVehicle() async -> Bool {
    switch await NetworkData.deleteVehicle.getDataSync() as Result<Bool?, CustomError> {
      case .success: return true
      case .failure: return false
    }
  }
  
  func getVehicles() async -> [Vehicle] {
    switch await NetworkData.getVehicles.getDataSync() as Result<[Vehicle]?, CustomError> {
      case .success(let vehicles): return vehicles ?? []
      case .failure: return []
    }
  }
  
  func getFavourites(userLocation: CLLocationCoordinate2D) async -> [LocationModel] {
    switch await NetworkData.getFavourites.getDataSync(extraURL: "/\(userLocation.latitude)/\(userLocation.longitude)") as Result<[LocationModel]?, CustomError> {
      case .success(let locations): return locations ?? []
      case .failure: return []
    }
  }
  
  func user(username: String, password: String) async -> Result<User?, CustomError> {
    return await NetworkData.user.getDataSync()
  }
  
  func user(token: String) async -> Result<User?, CustomError> {
    return await NetworkData.user.getDataSync(fetchUserToken: token)
  }
}

extension Repository: RepositoryProtocol {}

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

struct SomeView: View {
  @StateObject var viewModel: SomeViewModel
  
  init() {
    _viewModel = StateObject(wrappedValue: SomeViewModel(Repository()))
  }
  
  var body: some View {
    VStack {
      Text("Hello, World!")
    }
    .onAppear {
      viewModel.fetchVehicles()
    }
  }
}
