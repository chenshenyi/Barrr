import BarrrCore
import Testing

struct UserDefaultsToolLayoutStorageTests {
    @Test
    func loadsNothingWhenNeverSaved() {
        let storage = UserDefaultsToolLayoutStorage(center: UserDefaultsCenter(storage: InMemoryUserDefaultsStorage()))

        #expect(storage.load() == nil)
    }

    @Test
    func loadsSavedOrderAndHidden() {
        let defaults = InMemoryUserDefaultsStorage(values: [
            "toolOrder": ["performance", "noSleep"],
            "toolHidden": ["noSleep"],
        ])
        let storage = UserDefaultsToolLayoutStorage(center: UserDefaultsCenter(storage: defaults))

        #expect(storage.load() == ToolLayout(storedOrder: ["performance", "noSleep"], storedHidden: ["noSleep"]))
    }

    @Test
    func savesOrderAndHidden() async {
        let defaults = InMemoryUserDefaultsStorage()
        let storage = UserDefaultsToolLayoutStorage(center: UserDefaultsCenter(storage: defaults))
        var layout = ToolLayout()
        layout.move(from: 1, to: 0)
        layout.setVisible(.noSleep, false)

        storage.save(layout)

        #expect(await defaults.recordedWrites() == [
            .set(["performance", "noSleep"], key: "toolOrder"),
            .set(["noSleep"], key: "toolHidden"),
        ])
    }
}
