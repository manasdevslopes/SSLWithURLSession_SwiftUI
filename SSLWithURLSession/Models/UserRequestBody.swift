//
// UserRequestBody.swift
// SSLWithURLSession
//
// Created by MANAS VIJAYWARGIYA on 27/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import Foundation

struct UserRequestBody: Codable {
  var new_email: String?
  var provider: String?
  var email: String?
  var username: String?
  var password: String?
  var app_version: String?
  var firstName: String?
  var lastName: String?
}

