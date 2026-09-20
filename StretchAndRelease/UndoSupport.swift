//
//  UndoSupport.swift
//  StretchAndRelease
//
//  Drives AppDelegate.sharedUndoManager directly, rather than relying on
//  UIKit's built-in shake-to-undo. SwiftUI vends its own UndoManager into
//  the responder chain, which shadows the app delegate, so the system
//  gestures never see the manager SwiftData registers against.
//

import UIKit

@MainActor
enum UndoCoordinator {
    private static var manager: UndoManager { AppDelegate.sharedUndoManager }

    static func promptUndo() {
        let manager = manager
        guard manager.canUndo else { return }
        let name = manager.undoActionName
        prompt(title: name.isEmpty ? "Undo" : "Undo \(name)",
               confirm: name.isEmpty ? "Undo" : "Undo \(name)") { manager.undo() }
    }

    static func promptRedo() {
        let manager = manager
        guard manager.canRedo else { return }
        let name = manager.redoActionName
        prompt(title: name.isEmpty ? "Redo" : "Redo \(name)",
               confirm: name.isEmpty ? "Redo" : "Redo \(name)") { manager.redo() }
    }

    private static func prompt(title: String,
                               confirm: String,
                               action: @escaping () -> Void) {
        guard let presenter = topViewController() else { return }

        //Don't stack prompts if the user shakes repeatedly.
        guard !(presenter is UIAlertController) else { return }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirm, style: .default) { _ in action() })
        presenter.present(alert, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
}
