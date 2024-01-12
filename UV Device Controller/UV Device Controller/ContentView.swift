import SwiftUI
import CoreBluetooth

struct Theme {
    static let numberFont: Font = .system(size: 32.0, design: .monospaced)
    static let headFont: Font = .system(size: 32.0)
    static let ultraFont: Font = .system(size: 64.0)


}

struct CountdownTimerView: View {
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    @State private var timeRemaining = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var isConnected = false
    
    @State private var quickbutton01min = 0
    @State private var quickbutton01sec = 30
    
    @State private var quickbutton02min = 1
    @State private var quickbutton02sec = 00
    
    @State private var quickbutton03min = 2
    @State private var quickbutton03sec = 00
    
    let Hellgrau = Color(red: 0.85, green: 0.85, blue: 0.85)
    let Dunkelgrau = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    @Environment(\.colorScheme) var colorScheme

    private var bleManager: BLEManager!

    init() {
        self.bleManager = BLEManager(
            startAction: startTimer,
            stopAction: stopTimer,
            connectAction: connectToDevice
        )
    }

    var body: some View {
        VStack {
 
            Text("UV")
                .font(Theme.ultraFont)
                .foregroundColor(.purple)
                .bold(true)
                .shadow(color: Color.purple, radius: 10)
                .padding()
            
            Text("Exposure Controller")
                .font(Theme.headFont)
                .foregroundColor(.purple)
                .bold(true)


            
            HStack(spacing: 4) {
                Button(action: {
                    setTime(min: quickbutton01min,sec: quickbutton01sec)
                }) {
                    Text(String(format: "%02d:%02d", quickbutton01min, quickbutton01sec))
                        .font(Font.system(.body, design: .monospaced).monospacedDigit())
                        .padding()
                        .background(isTimerRunning ? Hellgrau : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                    quickbutton01min = selectedMinutes
                    quickbutton01sec = selectedSeconds
                })
                .padding()
                .disabled(isTimerRunning)

                
                Button(action: {
                    setTime(min: quickbutton02min,sec: quickbutton02sec)
                }) {
                    Text(String(format: "%02d:%02d", quickbutton02min, quickbutton02sec))
                        .font(Font.system(.body, design: .monospaced).monospacedDigit())
                        .padding()
                        .background(isTimerRunning ? Hellgrau : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                    quickbutton02min = selectedMinutes
                    quickbutton02sec = selectedSeconds
                })
                .padding()
                .disabled(isTimerRunning)
                
                Button(action: {
                    setTime(min: quickbutton03min,sec: quickbutton03sec)
                }) {
                    Text(String(format: "%02d:%02d", quickbutton03min, quickbutton03sec))
                        .font(Font.system(.body, design: .monospaced).monospacedDigit())
                        .padding()
                        .background(isTimerRunning ? Hellgrau : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                    quickbutton03min = selectedMinutes
                    quickbutton03sec = selectedSeconds
                })
                .padding()
                .disabled(isTimerRunning)

            }
            
            HStack(spacing: 20) {
                Button(action: {
                    adjustTime(increase: true, isMinutes: true, value: 10)
                }) {
                    Image(systemName: "plus.square.fill")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)

                Button(action: {
                    adjustTime(increase: true, isMinutes: true, value: 1)
                }) {
                    Image(systemName: "plus.square")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)

                Text(String(format: "%02d", selectedMinutes) + " min")
                    .font(Theme.numberFont)
                    .foregroundColor(isTimerRunning ? Color.purple : (colorScheme == .light ? Color.black : Color.white))
                    .bold(true)

                Button(action: {
                    adjustTime(increase: false, isMinutes: true, value: 1)
                }) {
                    Image(systemName: "minus.square")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)
                
                Button(action: {
                    adjustTime(increase: false, isMinutes: true, value: 10)
                }) {
                    Image(systemName: "minus.square.fill")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)
            }
            .padding()

            HStack(spacing: 20) {
                
                Button(action: {
                    adjustTime(increase: true, isMinutes: false, value: 10)
                }) {
                    Image(systemName: "plus.square.fill")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)
                
                Button(action: {
                    adjustTime(increase: true, isMinutes: false, value: 1)
                }) {
                    Image(systemName: "plus.square")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)

                Text(String(format: "%02d", selectedSeconds) + " sec")
                    .font(Theme.numberFont)
                    .foregroundColor(isTimerRunning ? Color.purple : (colorScheme == .light ? Color.black : Color.white))
                    .bold(true)
                
                Button(action: {
                    adjustTime(increase: false, isMinutes: false, value: 1)
                }) {
                    Image(systemName: "minus.square")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)
                
                Button(action: {
                    adjustTime(increase: false, isMinutes: false, value: 10)
                }) {
                    Image(systemName: "minus.square.fill")
                        .font(.title)
                        .foregroundColor(isTimerRunning ? Hellgrau : Color.purple)
                }
                .disabled(isTimerRunning)
            }
            .padding()

            Button(action: {
                if isTimerRunning {
                    stopTimer()
                    sendStopSignal()
                } else {
                    startTimer()
                    sendStartSignal()
                }
            }) {
                Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                    .padding()
                    .background(isTimerRunning ? Color.purple : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: isTimerRunning ? Color.purple : Color.white, radius: 10)
            }
            .padding()

            HStack {
                if isConnected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: 20, height: 20)
                    Text("Connected")
                        .foregroundColor(.green)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                    Text("Not Connected")
                        .foregroundColor(.red)
                }
            }
            .padding()

            Button(action: {
                connectToDevice()
            }) {
                HStack {
                    // Image("Bluetooth...
                    
                    Text("Connect")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)

                }
                .background(Color.blue)
                .cornerRadius(12)
                .padding()
            }
        }
        .padding()
    }

    func startTimer() {
        guard !isTimerRunning else { return }

        timeRemaining = selectedMinutes * 60 + selectedSeconds

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
                selectedSeconds = timeRemaining%60
                selectedMinutes = Int(floor(Double(timeRemaining)/60))
            } else {
                stopTimer()
                sendStopSignal()
            }
        }

        isTimerRunning = true
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timeRemaining = 0
        resetTime()
    }

    func sendStartSignal() {
        // let currentTime = Date()
        // let formattedTime = DateFormatter.localizedString(from: currentTime, dateStyle: .short, timeStyle: .medium)

        let startSignal = "on"
        bleManager.sendData(data: startSignal)
    }

    func sendStopSignal() {
        let stopSignal = "off"
        bleManager.sendData(data: stopSignal)
    }
    
    func setTime(min: Int, sec: Int) {
        selectedMinutes = min
        selectedSeconds = sec
    }

    func adjustTime(increase: Bool, isMinutes: Bool, value: Int) {
        if isMinutes {
            selectedMinutes += increase ? value : (selectedMinutes > 0 ? -value : 0)
            selectedMinutes = selectedMinutes > 0 ? selectedMinutes : 0
        } else {
            selectedSeconds += increase ? value : (selectedSeconds > 0 ? -value : 0)
            selectedSeconds = selectedSeconds > 0 ? selectedSeconds : 0
            if(selectedSeconds > 60) {
                selectedMinutes += Int(floor(Double(selectedSeconds)/60))
                selectedSeconds %= 60
            }
        }
    }

    func resetTime() {
        selectedMinutes = 0
        selectedSeconds = 0
    }

    func connectToDevice() {
        bleManager.connectToDevice()
    }
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic?
    private var startAction: (() -> Void)?
    private var stopAction: (() -> Void)?
    private var connectAction: (() -> Void)?
    
    private var yourServiceUUID: CBUUID
    private var yourCharacterisiticUUID: CBUUID
    
    var discoveredDevices: [CBPeripheral] = []

    init(startAction: @escaping () -> Void, stopAction: @escaping () -> Void, connectAction: @escaping () -> Void) {

        yourServiceUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
        yourCharacterisiticUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")

        super.init()

        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.startAction = { [weak self] in
            self?.startAction?()
        }
        self.stopAction = { [weak self] in
            self?.stopAction?()
        }
        self.connectAction = { [weak self] in
            self?.connectAction?()
        }
    }

    func sendData(data: String) {
        guard let characteristic = characteristic else {
            print("Characteristic not found.")
            return
        }

        let dataToSend = data.data(using: .utf8)
        peripheral.writeValue(dataToSend!, for: characteristic, type: .withResponse)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("BT is on.")
            scanForPeripheral()
        } else {
            print("Bluetooth is not available.")
        }
    }

    func scanForPeripheral() {
        print("SCANNING")
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]

        centralManager.scanForPeripherals(withServices: nil, options: options)
        // centralManager.scanForPeripherals(withServices: [yourServiceUUID], options: options)

    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
            // Check if the discovered peripheral is not already in the list
            if !discoveredDevices.contains(peripheral) {
                discoveredDevices.append(peripheral)
                print("Discovered device: \(peripheral.name ?? "Unknown")")
                print("Peripheral Identifier: \(peripheral.identifier)")
                print("Advertisement Data: \(advertisementData)")
                print("RSSI: \(RSSI)")
                print("===========")
                if(peripheral.name=="UART Service") {
                    centralManager.stopScan()
                    self.peripheral = peripheral
                    centralManager.connect(self.peripheral, options: nil)
                }
            }
        }
/*
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        print("DISCOVERED")
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(self.peripheral, options: nil)
    }
*/
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("CONNECTED")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        // connectAction?()  // Trigger connect action when peripheral is connected
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print(service.uuid)
                peripheral.discoverCharacteristics([yourCharacterisiticUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic.uuid)
                self.characteristic = characteristic
                /* if characteristic.properties.contains(.write) {
                    self.characteristic = characteristic
                    startAction?()  // Trigger start action when characteristic is found
                }*/
            }
        }
    }

    func connectToDevice() {
        scanForPeripheral()
    }
}

