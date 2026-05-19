//  BusDetailsViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Services
import Foundation

@Observable
final class BusRoutesViewModel: ViewModel {

    let busRoutes: BusRoutes
    init(_ busRoutes: BusRoutes) {
        self.busRoutes = busRoutes
    }

    func task() {
        //		do {
//
        //		} catch {
        //			showError(error)
        //		}
    }
}
