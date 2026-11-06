import Testing
@testable import BarrrCore

struct UserDefaultsCenterTests {
    @Test
    func readsStoredValueByKeyName() {
        let center = UserDefaultsCenter(storage: InMemoryUserDefaultsStorage(values: ["toolOrder": ["noSleep"]]))

        #expect(center.value(for: .toolOrder) == ["noSleep"])
    }

    @Test
    func missingValueIsNil() {
        let center = UserDefaultsCenter(storage: InMemoryUserDefaultsStorage())

        #expect(center.value(for: .toolHidden) == nil)
    }

    @Test
    func writesAndRemovesByKeyName() async {
        let storage = InMemoryUserDefaultsStorage()
        let center = UserDefaultsCenter(storage: storage)

        center.setValue(["performance"], for: .toolHidden)
        center.removeValue(for: UserDefaultsKey<[String]>.toolOrder)

        #expect(await storage.recordedWrites() == [.set(["performance"], key: "toolHidden"), .remove(key: "toolOrder")])
    }
}
