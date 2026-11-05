/// 指令列參數無法解析的原因
public enum CommandError: Error, Equatable {
    /// 未知的指令或參數個數不對
    case invalidArguments([String])
    /// `start` 後面不是已知的方式
    case unknownMode(String)
}
