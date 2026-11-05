/// SwiftBar 顯示的內容：選單列上的圖示與點開後的選單
public struct Menu: Equatable, Sendable {
    /// 選單列上的圖示
    public let header: MenuItem
    public let lines: [MenuLine]

    public init(state: MenuState) {
        let activeMode: AwakeMode?
        let status: String
        switch state {
        case .sleepAllowed:
            header = MenuItem(title: "", symbol: MenuText.sleepAllowedSymbol)
            activeMode = nil
            status = MenuText.sleepAllowed
        case let .awake(mode):
            header = MenuItem(title: "", symbol: MenuText.awakeSymbol)
            activeMode = mode
            status = MenuText.awake
        case let .unknown(error):
            header = MenuItem(title: "", symbol: MenuText.unknownSymbol)
            activeMode = nil
            status = MenuText.description(of: error)
        }
        // 點已勾選的方式等於恢復休眠
        let modes = AwakeMode.allCases.map { mode in
            let isActive = mode == activeMode
            return MenuLine.item(MenuItem(
                title: MenuText.title(of: mode),
                command: isActive ? .stop : .start(mode),
                isChecked: isActive
            ))
        }
        let resume: [MenuLine] = state == .sleepAllowed
            ? []
            : [.separator, .item(MenuItem(title: MenuText.resume, command: .stop))]
        lines = [.item(MenuItem(title: status)), .separator] + modes + resume
    }
}
