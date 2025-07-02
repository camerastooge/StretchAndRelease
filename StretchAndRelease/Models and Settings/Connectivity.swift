//
//  Connectivity.swift
//  StretchAndRelease
//
//  Created by Lucas Barker on 6/27/25.
//

import Foundation
import WatchConnectivity

@Observable
class Connectivity: NSObject, WCSessionDelegate {
    var statusText = ""
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    #if os(iOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    statusText = "Connection Established"
                }
            }
        }
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    #else
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    #endif
    
}
