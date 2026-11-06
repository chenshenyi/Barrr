import Darwin
import PerformanceCore

/// 網路：`getifaddrs` 的連結層（AF_LINK）統計
extension LiveSystemMetricsReader {
    func networkCounters() throws(SystemMetricsError) -> NetworkCounters {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else {
            throw .networkUnavailable(code: errno)
        }
        defer { freeifaddrs(list) }
        var interfaces: [String: InterfaceCounters] = [:]
        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let entry = pointer.pointee
            // 不計 loopback 與點對點介面（VPN 的 utun 會和實體介面重複計算同一份流量）
            let excludedFlags = UInt32(IFF_LOOPBACK | IFF_POINTOPOINT)
            guard let address = entry.ifa_addr, address.pointee.sa_family == UInt8(AF_LINK),
                  let data = entry.ifa_data, entry.ifa_flags & excludedFlags == 0
            else {
                continue
            }
            let statistics = data.assumingMemoryBound(to: if_data.self).pointee
            interfaces[String(cString: entry.ifa_name)] = InterfaceCounters(
                received: statistics.ifi_ibytes,
                sent: statistics.ifi_obytes
            )
        }
        return NetworkCounters(interfaces: interfaces)
    }
}
