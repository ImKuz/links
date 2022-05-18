import Foundation

public extension String {

    var isLink: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && count > 0) else { return false }
        if detector!.numberOfMatches(
            in: self,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, count)
        ) > 0 {
            return true
        }

        return false
    }
}
