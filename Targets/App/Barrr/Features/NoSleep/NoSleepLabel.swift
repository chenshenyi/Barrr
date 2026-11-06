import NoSleepCore
import SwiftUI

/// 不休眠在選單列的圖示：月亮是照系統設定休眠，咖啡杯是保持清醒
@MainActor
struct NoSleepLabel: View {
    let activeMode: AwakeMode?

    var body: some View {
        Image(activeMode == nil ? AppSymbol.sleepAllowed : .awake)
    }
}
