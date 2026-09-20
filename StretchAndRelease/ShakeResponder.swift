//
//  ShakeResponder.swift
//  StretchAndRelease
//
//  Motion events are delivered to the first responder and then up the chain.
//  A pure SwiftUI hierarchy often has no first responder at all, so nothing
//  is delivered anywhere. This installs one.
//
//  Note: do NOT set UIApplicationSupportsShakeToEdit to NO in Info.plist.
//  That suppresses shake motion delivery to the app entirely, not just
//  UIKit's built-in undo UI, and this controller stops receiving events.
//

import SwiftUI
import UIKit

struct ShakeResponder: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ShakeResponderController {
        ShakeResponderController()
    }

    func updateUIViewController(_ uiViewController: ShakeResponderController,
                                context: Context) {}
}

final class ShakeResponderController: UIViewController {
    override var canBecomeFirstResponder: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Text fields take first responder while editing and don't hand it
        //back, which would silently kill shake-to-undo for the rest of the
        //session. Reclaim it once the keyboard goes away.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(claimFirstResponder),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        claimFirstResponder()
    }

    @objc private func claimFirstResponder() {
        guard view.window != nil, !isFirstResponder else { return }
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            super.motionEnded(motion, with: event)
            return
        }
        UndoCoordinator.promptUndo()
    }
}
