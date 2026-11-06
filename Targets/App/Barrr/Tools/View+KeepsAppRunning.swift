import SwiftUI

extension View {
    /// App 啟動完成後關閉自動終止；掛在常駐的選單列圖示上，`.task` 確保在 SwiftUI 的啟動設定之後才執行
    func keepsAppRunning(_ keepRunning: @escaping @MainActor () -> Void) -> some View {
        task {
            keepRunning()
        }
    }
}
