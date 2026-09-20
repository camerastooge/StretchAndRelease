//
//  AppDelegate.swift
//  StretchAndRelease
//

import UIKit

/// Owns the app's undo manager and vends it to the UIKit responder chain.
///
/// `UIResponder`'s default `undoManager` returns `next?.undoManager`, and
/// `UIApplication`'s next responder is the app delegate, so this is the
/// fallback for any lookup that walks the chain without finding one sooner.
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// The single manager shared by SwiftData and the undo gestures.
    /// `StretchAndReleaseApp` assigns this to the model context.
    static let sharedUndoManager = UndoManager()

    override var undoManager: UndoManager? { AppDelegate.sharedUndoManager }
}
