import Foundation

/// 輸出結果並結束 process：成功的內容寫到 stdout（SwiftBar 讀取），失敗的寫到 stderr
struct LiveTerminal: Sendable {
    private static let newline = "\n"

    func finish(lines: [String], succeeded: Bool) -> Never {
        let output = succeeded ? FileHandle.standardOutput : FileHandle.standardError
        output.write(Data(lines.map { $0 + Self.newline }.joined().utf8))
        exit(succeeded ? EXIT_SUCCESS : EXIT_FAILURE)
    }
}
