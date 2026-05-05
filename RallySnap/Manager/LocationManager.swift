//
//  LocationManager.swift
//  RallySnap
//
//  Created by Belmiro Kayru on 05/05/26.
//
import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject,
  CLLocationManagerDelegate {
      private let manager = CLLocationManager()
      @Published var authorizationStatus: CLAuthorizationStatus
  = .notDetermined

      override init() {
          super.init()
          manager.delegate = self
          authorizationStatus = manager.authorizationStatus
      }

      func requestPermission() {
          manager.requestWhenInUseAuthorization()
      }

      func locationManagerDidChangeAuthorization(_ manager:
  CLLocationManager) {
          authorizationStatus = manager.authorizationStatus
      }
  }

