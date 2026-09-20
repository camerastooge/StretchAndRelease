//
//  UndoGestures.swift
//  StretchAndRelease
//
//  Attaches the three-finger undo/redo swipes to the window. They go on the
//  window rather than on a view so they work anywhere in the app, and
//  cancelsTouchesInView is off so they don't interfere with list scrolling,
//  swipe-to-delete, or drag-to-reorder.
//

import SwiftUI
import UIKit

struct UndoGestures: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView { UndoGestureAttachingView() }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

final class UndoGestureAttachingView: UIView {
    private var hasAttached = false

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard !hasAttached, let window else { return }
        hasAttached = true

        let undo = UISwipeGestureRecognizer(target: self, action: #selector(handleUndo))
        undo.direction = .left

        let redo = UISwipeGestureRecognizer(target: self, action: #selector(handleRedo))
        redo.direction = .right

        for gesture in [undo, redo] {
            gesture.numberOfTouchesRequired = 3
            gesture.cancelsTouchesInView = false
            window.addGestureRecognizer(gesture)
        }
    }

    @objc private func handleUndo() { UndoCoordinator.promptUndo() }
    @objc private func handleRedo() { UndoCoordinator.promptRedo() }
}
