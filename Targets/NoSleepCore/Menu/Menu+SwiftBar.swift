extension Menu {
    private static let lineSeparator = "---"
    private static let titleSeparator = " | "
    private static let parameterSeparator = " "
    private static let symbolKey = "sfimage="
    private static let checked = "checked=true"
    private static let executableKey = "bash="
    private static let parameterKeyPrefix = "param"
    private static let valueSeparator = "="
    private static let quote = "\""
    /// 在背景執行，結束後立即重新整理選單
    private static let actionOptions = ["terminal=false", "refresh=true"]

    /// SwiftBar 的輸出格式：每行 `標題 | key=value …`，`---` 之前是選單列、之後是選單
    /// - Parameter executablePath: 點選項目時要執行的檔案（也就是自己）
    public func swiftBarLines(executablePath: String) -> [String] {
        let body = lines.map { line in
            switch line {
            case let .item(item): Self.swiftBarLine(item, executablePath: executablePath)
            case .separator: Self.lineSeparator
            }
        }
        return [Self.swiftBarLine(header, executablePath: executablePath), Self.lineSeparator] + body
    }

    private static func swiftBarLine(_ item: MenuItem, executablePath: String) -> String {
        var parameters: [String] = []
        if let symbol = item.symbol {
            parameters.append(symbolKey + symbol)
        }
        if item.isChecked {
            parameters.append(checked)
        }
        if let command = item.command {
            parameters.append(executableKey + quote + executablePath + quote)
            for (index, argument) in command.arguments.enumerated() {
                parameters.append(parameterKeyPrefix + String(index + 1) + valueSeparator + argument)
            }
            parameters += actionOptions
        }
        guard !parameters.isEmpty else {
            return item.title
        }
        return item.title + titleSeparator + parameters.joined(separator: parameterSeparator)
    }
}
