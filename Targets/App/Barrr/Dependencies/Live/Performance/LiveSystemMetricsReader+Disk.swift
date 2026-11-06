import Foundation
import IOKit
import PerformanceCore

/// 磁碟：開機磁碟的空間（URL resource values），所有磁碟累計的讀寫（IORegistry 的 `IOBlockStorageDriver`）
extension LiveSystemMetricsReader {
    private enum Disk: Sendable {
        static let bootVolume = URL(filePath: "/")
        static let driverClass = "IOBlockStorageDriver"
        static let statistics = "Statistics"
        static let bytesRead = "Bytes (Read)"
        static let bytesWritten = "Bytes (Write)"
    }

    func diskUsage() throws(SystemMetricsError) -> DiskUsage {
        let values: URLResourceValues
        do {
            values = try Disk.bootVolume.resourceValues(forKeys: [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeTotalCapacityKey,
            ])
        } catch {
            throw .diskUnavailable
        }
        guard let available = values.volumeAvailableCapacityForImportantUsage,
              let total = values.volumeTotalCapacity
        else {
            throw .diskUnavailable
        }
        return DiskUsage(available: UInt64(max(available, 0)), total: UInt64(max(total, 0)))
    }

    func diskTransfer() throws(SystemMetricsError) -> TransferCounters {
        var iterator = io_iterator_t()
        guard IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching(Disk.driverClass), &iterator) ==
            KERN_SUCCESS
        else {
            throw .diskTransferUnavailable
        }
        defer { IOObjectRelease(iterator) }
        var read: UInt64 = 0
        var written: UInt64 = 0
        var service = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            if let properties = IORegistryProperties.read(service),
               let statistics = UntypedValue.dictionary(properties[Disk.statistics])
            {
                read += UntypedValue.unsignedInteger(statistics[Disk.bytesRead]) ?? 0
                written += UntypedValue.unsignedInteger(statistics[Disk.bytesWritten]) ?? 0
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        return TransferCounters(incoming: read, outgoing: written)
    }
}
