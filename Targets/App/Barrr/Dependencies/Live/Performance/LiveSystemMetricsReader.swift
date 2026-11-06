import Darwin
import Foundation
import PerformanceCore

/// 讀取系統數據；CPU 與記憶體在本檔（Mach 的 host statistics，與「活動監視器」相同的資料來源），能耗、磁碟、網路在各自的 extension
struct LiveSystemMetricsReader: SystemMetricsReader, Sendable {
    func cpuTicks() throws(SystemMetricsError) -> CPUTicks {
        var info = host_cpu_load_info_data_t()
        let capacity = MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size
        var count = mach_msg_type_number_t(capacity)
        let host = mach_host_self()
        defer { mach_port_deallocate(mach_task_self_, host) }
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                host_statistics(host, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            throw .cpuUnavailable(code: result)
        }
        // cpu_ticks 依 CPU_STATE_USER、CPU_STATE_SYSTEM、CPU_STATE_IDLE、CPU_STATE_NICE 排列
        let ticks = info.cpu_ticks
        return CPUTicks(user: UInt64(ticks.0), system: UInt64(ticks.1), idle: UInt64(ticks.2), nice: UInt64(ticks.3))
    }

    func memoryUsage() throws(SystemMetricsError) -> MemoryUsage {
        var stats = vm_statistics64_data_t()
        let capacity = MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        var count = mach_msg_type_number_t(capacity)
        let host = mach_host_self()
        defer { mach_port_deallocate(mach_task_self_, host) }
        let result = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                host_statistics64(host, HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            throw .memoryUnavailable(code: result)
        }
        var pageSize = vm_size_t()
        let pageResult = host_page_size(host, &pageSize)
        guard pageResult == KERN_SUCCESS else {
            throw .memoryUnavailable(code: pageResult)
        }
        // 「活動監視器」的已使用記憶體 = App 記憶體（internal − purgeable）+ 聯繫 + 壓縮
        let internalPages = UInt64(stats.internal_page_count)
        let purgeablePages = UInt64(stats.purgeable_count)
        let appPages = internalPages > purgeablePages ? internalPages - purgeablePages : 0
        let usedPages = appPages + UInt64(stats.wire_count) + UInt64(stats.compressor_page_count)
        return MemoryUsage(used: usedPages * UInt64(pageSize), total: ProcessInfo.processInfo.physicalMemory)
    }
}
