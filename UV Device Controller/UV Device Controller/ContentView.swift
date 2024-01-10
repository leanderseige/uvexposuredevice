import SwiftUI
import CoreBluetooth

struct CountdownTimerView: View {
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    @State private var timeRemaining = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?

    private var bleManager: BLEManager!

    init() {
            self.bleManager = BLEManager(
                startAction: startTimer,
                stopAction: stopTimer
            )
        }

    var body: some View {
        VStack {
            if !isTimerRunning {
                HStack {
                    Picker("Minutes", selection: $selectedMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute) min")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)

                    Picker("Seconds", selection: $selectedSeconds) {
                        ForEach(0..<60) { second in
                            Text("\(second) sec")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                }
                .padding()

                HStack(spacing: 20) {
                    Button(action: {
                        quickSelectTime(minutes: 0, seconds: 30)
                    }) {
                        Text("30 sec")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        quickSelectTime(minutes: 1, seconds: 0)
                    }) {
                        Text("1 min")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        quickSelectTime(minutes: 2, seconds: 0)
                    }) {
                        Text("2 min")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        quickSelectTime(minutes: 3, seconds: 0)
                    }) {
                        Text("3 min")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                Button(action: {
                    startTimer()
                    sendStartSignal()
                }) {
                    Text("Start Timer")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("Time Remaining:")
                    .font(.title)
                    .padding()

                Text("\(timeRemaining / 60) min \(timeRemaining % 60) sec")
                    .font(.largeTitle)
                    .padding()

                Spacer()

                Button(action: {
                    stopTimer()
                    sendStopSignal()
                }) {
                    Text("Stop Timer")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    func startTimer() {
        guard !isTimerRunning else { return }

        timeRemaining = selectedMinutes * 60 + selectedSeconds

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }

        isTimerRunning = true
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timeRemaining = 0
    }

    func sendStartSignal() {
        let currentTime = Date()
        let formattedTime = DateFormatter.localizedString(from: currentTime, dateStyle: .short, timeStyle: .medium)

        let startSignal = "START\(formattedTime)"
        bleManager.sendData(data: startSignal)
    }

    func sendStopSignal() {
        let stopSignal = "STOP"
        bleManager.sendData(data: stopSignal)
    }

    func quickSelectTime(minutes: Int, seconds: Int) {
        selectedMinutes = minutes
        selectedSeconds = seconds
    }
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic?
    private var startAction: (() -> Void)?
    private var stopAction: (() -> Void)?
    
    init(startAction: @escaping () -> Void, stopAction: @escaping () -> Void) {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.startAction = { [unowned self] in
            self.startAction?()
        }
        self.stopAction = { [unowned self] in
            self.stopAction?()
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
            scanForPeripheral()
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func scanForPeripheral() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        
    }
    
}
