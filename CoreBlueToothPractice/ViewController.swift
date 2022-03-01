//
//  ViewController.swift
//  CoreBlueToothPractice
//
//  Created by hoseung Lee on 2022/03/01.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

  var centralManager: CBCentralManager!
  var airpods: CBPeripheral!

  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
}


extension ViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {

      case .unknown:
        print("central.state is .unknown")
      case .resetting:
        print("central.state is .resetting")
      case .unsupported:
        print("central.state is .unsupprted")
      case .unauthorized:
        print("central.state is .unauthorized")
      case .poweredOff:
        print("central.state is .poweredOff")
      case .poweredOn:
        print("central.state is .poerwedOn")
        let audioServiceCBUUID: [CBUUID] = [
          CBUUID(string: "0x1810"),
        ]
        centralManager.scanForPeripherals(withServices: nil)
      @unknown default:
        print("central.state is .unknown default")
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print(peripheral)
    if peripheral.name ?? "" == "둥둥팟" {
      airpods = peripheral
      centralManager.connect(airpods, options: nil)
      airpods.delegate = self
      centralManager.stopScan()
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    airpods.discoverServices(nil)
    print("Connect to: \(peripheral)")
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print(#function)
    print("Fail to \(peripheral) error: \(error?.localizedDescription)")
  }
}

extension ViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else {
      return
    }

    for service in services {
      print(peripheral.discoverCharacteristics(nil, for: service))
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else {
      print("didfail didscover characteristics with error: \(error)")
      return
    }

    for characteristic in characteristics {
      peripheral.readValue(for: characteristic)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic.uuid == CBUUID(string: "배터리상태") {
      print(batteryState(from: characteristic))
    }
  }

  private func batteryState(from characteristic: CBCharacteristic) -> Int {
    guard let data = characteristic.value else { return -1 }
    print([UInt8](data))
    return -1
  }
}
