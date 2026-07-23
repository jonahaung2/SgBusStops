//  AppInfo.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum AppInfo {
    public static var marketing: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    public static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    public static var full: String {
        "\(marketing) (\(build))"
    }

    public static let groupIdentifier: String = "group.com.aungkomin.SG-Bus-Stops"
}
