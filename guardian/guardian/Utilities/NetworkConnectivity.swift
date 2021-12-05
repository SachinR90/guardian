//
//  NetworkConnectivity.swift
//  guardian
//
//  Created by Sachin Rao on 05/12/21.
//

import Foundation
import Network

extension Notification.Name {
  static let connectivityChanged = Notification.Name("com.example.networkconnectivitychanged")
}

struct ConnectivityStatus {
  /// An NWPath status indicates if there is a usable route available upon which to send and receive data.
  public enum Status {
    /// The path has a usable route upon which to send and receive data
    case connected

    /// The path does not have a usable route. This may be due to a network interface being down, or due to system policy. or
    /// The path does not currently have a usable route, but a connection attempt will trigger network attachment.
    case notConnected
  }

  public let status: ConnectivityStatus.Status

  /// Checks if the path uses an NWInterface that is considered to be expensive
  ///
  /// Cellular interfaces are considered expensive. WiFi hotspots from an iOS device are considered expensive. Other
  /// interfaces may appear as expensive in the future.
  public let isExpensive: Bool
}

private extension NWPath {
  func mapToConnectivityStatus() -> ConnectivityStatus {
    switch status {
      case .satisfied:
        return ConnectivityStatus(status: .connected, isExpensive: isExpensive)
      default:
        break
    }

    return ConnectivityStatus(status: .notConnected, isExpensive: isExpensive)
  }
}

protocol Connectivity {
  var currentStatus: ConnectivityStatus { get }
  func startMonitoring()
  func stopMonitoring()
}

final class NetworkConnectivity: Connectivity {
  static let shared: NetworkConnectivity = {
    NetworkConnectivity()
  }()

  // JUST for debugging
//    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
  let monitor = NWPathMonitor()
  let monitorQueue: DispatchQueue

  private var previousStatus: ConnectivityStatus.Status?
  var currentStatus: ConnectivityStatus {
    monitor.currentPath.mapToConnectivityStatus()
  }

  init(queue: DispatchQueue = DispatchQueue(label: "com.example.connectivity")) {
    monitorQueue = queue

    // NOTE: Below handler only called in the device, not in simulator
    monitor.pathUpdateHandler = { path in
      if let previous = self.previousStatus,
         previous == path.mapToConnectivityStatus().status
      {
        return
      }
      self.previousStatus = path.mapToConnectivityStatus().status
      NotificationCenter.default.post(name: .connectivityChanged,
                                      object: path.mapToConnectivityStatus())
    }
  }

  func startMonitoring() {
    monitor.start(queue: monitorQueue)
  }

  func stopMonitoring() {
    monitor.cancel()
  }
}
