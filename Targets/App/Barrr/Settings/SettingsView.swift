import BarrrCore
import SwiftUI

/// 管理視窗：工具的順序與顯示、App 共用的設定與結束
@MainActor
struct SettingsView: View {
    private static let width: CGFloat = 440
    private static let spacing: CGFloat = 24
    private static let padding: CGFloat = 28

    @Binding var model: SettingsModel
    let appIcon: Image
    let setVisible: @MainActor (Tool, Bool) -> Void
    let quit: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Self.spacing) {
            SettingsHeader(appIcon: appIcon)
            ToolList(
                layout: model.layout,
                setVisible: setVisible,
                move: { model.moveTool(from: $0, to: $1) }
            )
            GeneralSection(
                launchesAtLogin: Binding(get: { model.launchesAtLogin }, set: { model.setLaunchesAtLogin($0) }),
                failure: model.failure
            )
            HStack {
                Spacer()
                Button(action: quit) {
                    Text(.settingsQuit)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(Self.padding)
        .frame(width: Self.width)
        .fixedSize(horizontal: false, vertical: true)
        // 整個視窗是一塊玻璃：視窗的背景拿掉（BarrrApp 的 containerBackground），玻璃延伸到隱藏的標題列；
        // 裡面的卡片只用淡底色分區，不再疊玻璃
        .background {
            Rectangle()
                .fill(.clear)
                .glassEffect(.regular, in: .rect)
                .ignoresSafeArea()
        }
    }
}
