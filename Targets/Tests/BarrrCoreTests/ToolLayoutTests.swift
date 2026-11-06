import BarrrCore
import Testing

struct ToolLayoutTests {
    @Test
    func defaultShowsAllToolsInDeclarationOrder() {
        let layout = ToolLayout()

        #expect(layout.visibleTools == Tool.allCases)
    }

    @Test
    func restoresStoredOrderAndHidden() {
        let layout = ToolLayout(storedOrder: ["performance", "noSleep"], storedHidden: ["noSleep"])

        #expect(layout.order == [.performance, .noSleep])
        #expect(layout.visibleTools == [.performance])
    }

    @Test
    func restoringIgnoresUnknownAndDuplicateIdentifiersAndAppendsNewTools() {
        let layout = ToolLayout(
            storedOrder: ["performance", "removedTool", "performance"],
            storedHidden: ["removedTool"]
        )

        #expect(layout.order == [.performance, .noSleep])
        #expect(layout.visibleTools == [.performance, .noSleep])
    }

    @Test
    func restoringAllHiddenShowsFirstTool() {
        let layout = ToolLayout(storedOrder: ["performance", "noSleep"], storedHidden: ["noSleep", "performance"])

        #expect(layout.visibleTools == [.performance])
    }

    @Test
    func storedIdentifiersRoundTrip() {
        var layout = ToolLayout()
        layout.move(from: 1, to: 0)
        layout.setVisible(.noSleep, false)

        let restored = ToolLayout(storedOrder: layout.storedOrder, storedHidden: layout.storedHidden)

        #expect(restored == layout)
    }

    @Test
    func lastVisibleToolCannotBeHidden() {
        var layout = ToolLayout()
        layout.setVisible(.noSleep, false)

        layout.setVisible(.performance, false)

        #expect(layout.visibleTools == [.performance])
        #expect(!layout.canHide(.performance))
    }

    @Test
    func hiddenToolCanBeShownAgain() {
        var layout = ToolLayout()
        layout.setVisible(.noSleep, false)

        layout.setVisible(.noSleep, true)

        #expect(layout.visibleTools == Tool.allCases)
    }

    @Test(arguments: [
        (1, 0, [Tool.performance, .noSleep]),
        (0, 2, [Tool.performance, .noSleep]),
        (0, 1, [Tool.noSleep, .performance]),
        (0, 0, [Tool.noSleep, .performance]),
    ])
    func moveFollowsOnMoveSemantics(source: Int, destination: Int, expected: [Tool]) {
        var layout = ToolLayout()

        layout.move(from: source, to: destination)

        #expect(layout.order == expected)
    }

    @Test(arguments: [(-1, 0), (2, 0), (0, 3)])
    func moveIgnoresOutOfRangeIndexes(source: Int, destination: Int) {
        var layout = ToolLayout()

        layout.move(from: source, to: destination)

        #expect(layout.order == Tool.allCases)
    }
}
