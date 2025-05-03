//
// SomeView.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 03/05/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

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

#Preview {
  SomeView()
}
