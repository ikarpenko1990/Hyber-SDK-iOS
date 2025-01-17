//
// Formatters.swift
//  Hyber-SDK
//
//  Created by Taras on 10/27/16.
//  Incuube
//

extension Formatters {
    public static let `default` = Formatter("[%@] %@ %@: %@", [
        .date("yyyy-MM-dd HH:mm:ss.SSS"),
        .location,
        .level,
        .message
    ])
    
    public static let minimal = Formatter("%@: %@", [
        .level,
        .message
    ])
    
    public static let detailed = Formatter("[%@] %@.%@:%@ %@: %@", [
        .date("yyyy-MM-dd HH:mm:ss.SSS"),
        .file(fullPath: false, fileExtension: false),
        .function,
        .line,
        .level,
        .message
    ])
}
