import Foundation

extension String? {
    func transformOrEmpty(transformer: (String) -> String) -> String {
        guard let self else {
            return ""
        }

        return transformer(self)
    }
}
