import Testing
@testable import NoSleepCore

struct MenuTests {
    @Test
    func sleepAllowedOffersEachMode() {
        let menu = Menu(state: .sleepAllowed)

        #expect(menu.swiftBarLines(executablePath: "/plugins/nosleep.1m.bin") == [
            " | sfimage=moon.zzz",
            "---",
            "休眠：照系統設定",
            "---",
            "不休眠（螢幕保持亮） | bash=\"/plugins/nosleep.1m.bin\" param1=start param2=display terminal=false refresh=true",
            "不休眠（螢幕可關閉） | bash=\"/plugins/nosleep.1m.bin\" param1=start param2=system terminal=false refresh=true",
        ])
    }

    @Test
    func awakeChecksActiveModeThatStopsWhenSelected() {
        let menu = Menu(state: .awake(.allowDisplaySleep))

        #expect(menu.swiftBarLines(executablePath: "/p/nosleep") == [
            " | sfimage=cup.and.heat.waves.fill",
            "---",
            "休眠已關閉",
            "---",
            "不休眠（螢幕保持亮） | bash=\"/p/nosleep\" param1=start param2=display terminal=false refresh=true",
            "不休眠（螢幕可關閉） | checked=true bash=\"/p/nosleep\" param1=stop terminal=false refresh=true",
            "---",
            "恢復休眠 | bash=\"/p/nosleep\" param1=stop terminal=false refresh=true",
        ])
    }

    @Test
    func unknownStateShowsErrorAndOffersResume() {
        let menu = Menu(state: .unknown(.launchctlFailed(status: 5)))

        #expect(menu.header.symbol == "exclamationmark.triangle")
        #expect(menu.lines.first == .item(MenuItem(title: "launchctl 執行失敗，狀態 5")))
        #expect(menu.lines.last == .item(MenuItem(title: "恢復休眠", command: .stop)))
    }

    @Test
    func pathWithSpacesIsQuoted() {
        let menu = Menu(state: .sleepAllowed)

        let lines = menu.swiftBarLines(executablePath: "/Users/me/SwiftBar Plugins/nosleep.1m.bin")

        #expect(lines.contains { $0.contains("bash=\"/Users/me/SwiftBar Plugins/nosleep.1m.bin\"") })
    }
}
