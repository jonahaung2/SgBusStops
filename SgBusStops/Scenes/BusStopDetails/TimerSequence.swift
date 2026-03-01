//
//  TimerSequence.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import Foundation

struct TimerSequence: AsyncSequence {
    typealias Element = Void

    let interval: Duration

    init(every interval: Duration) {
        self.interval = interval
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        let interval: Duration

        mutating func next() async -> Void? {
            do {
                try await Task.sleep(for: interval)
            } catch {
                return nil
            }
            guard !Task.isCancelled else {
                return nil
            }
            return ()
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(interval: interval)
    }
}
