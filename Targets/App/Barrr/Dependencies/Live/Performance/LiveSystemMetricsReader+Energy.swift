import IOKit
import PerformanceCore

/// 電池與系統耗電：IORegistry 的 `AppleSmartBattery`（與 `ioreg -rn AppleSmartBattery` 相同的資料）
extension LiveSystemMetricsReader {
    private enum Battery: Sendable {
        static let serviceClass = "AppleSmartBattery"
        static let currentCapacity = "CurrentCapacity"
        static let maxCapacity = "MaxCapacity"
        static let isCharging = "IsCharging"
        static let isFullyCharged = "FullyCharged"
        static let isExternalConnected = "ExternalConnected"
        /// 子字典，`SystemLoad` 是整台 Mac 目前的耗電（毫瓦）
        static let powerTelemetry = "PowerTelemetryData"
        static let systemLoad = "SystemLoad"
        static let milliwattsPerWatt: Double = 1000
    }

    func energyStatus() throws(SystemMetricsError) -> EnergyStatus {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(Battery.serviceClass))
        // 沒有電池的 Mac（桌上型）
        guard service != IO_OBJECT_NULL else {
            return EnergyStatus(battery: nil, systemPowerWatts: nil)
        }
        defer { IOObjectRelease(service) }
        guard let properties = IORegistryProperties.read(service) else {
            throw .energyUnavailable
        }
        let state = BatteryState(
            isCharging: UntypedValue.boolean(properties[Battery.isCharging]) ?? false,
            isFullyCharged: UntypedValue.boolean(properties[Battery.isFullyCharged]) ?? false,
            isExternalConnected: UntypedValue.boolean(properties[Battery.isExternalConnected]) ?? false
        )
        let battery: BatteryLevel? = if let current = UntypedValue.integer(properties[Battery.currentCapacity]),
                                        let max = UntypedValue.integer(properties[Battery.maxCapacity])
        {
            BatteryLevel(currentCapacity: current, maxCapacity: max, state: state)
        } else {
            nil
        }
        let telemetry = UntypedValue.dictionary(properties[Battery.powerTelemetry])
        let watts = UntypedValue.integer(telemetry?[Battery.systemLoad]).map { Double($0) / Battery.milliwattsPerWatt }
        return EnergyStatus(battery: battery, systemPowerWatts: watts)
    }
}
