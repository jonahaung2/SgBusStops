//  TextSearch.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum TextSearch {
    // MARK: - Public API

    @inline(__always)
    public static func matches(
        text: String,
        query: String,
        typoTolerance: Int = 1
    ) -> Bool {
        let queryTokens = tokens(query)
        if queryTokens.isEmpty { return true }

        let textTokens = tokens(text)

        for q in queryTokens {
            var matched = false

            for t in textTokens {
                if t.hasPrefix(q) || t.contains(q) {
                    matched = true
                    break
                }

                if typoTolerance > 0,
                   levenshtein(q, t) <= typoTolerance
                {
                    matched = true
                    break
                }
            }

            if !matched {
                return false
            }
        }

        return true
    }

    // MARK: - Tokenizer

    @inline(__always)
    public static func tokens(_ text: String) -> [String] {
        text
            .folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
    }

    // MARK: - Levenshtein

    static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)

        var dist = Array(
            repeating: Array(repeating: 0, count: bChars.count + 1),
            count: aChars.count + 1
        )

        for i in 0 ... aChars.count {
            dist[i][0] = i
        }
        for j in 0 ... bChars.count {
            dist[0][j] = j
        }

        for i in 1 ... aChars.count {
            for j in 1 ... bChars.count {
                dist[i][j] = if aChars[i - 1] == bChars[j - 1] {
                    dist[i - 1][j - 1]
                } else {
                    Swift.min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[aChars.count][bChars.count]
    }
}
