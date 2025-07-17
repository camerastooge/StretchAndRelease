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
    var didStatusChange = false
    var statusContext: [String: Any] = ["stretch" : 0, "rest" : 0, "reps" : 0]
    
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
                    self.statusText = "CONNECTED"
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
    
    func setContext(to data: [String : Any]) {
        let session = WCSession.default
        if session.activationState == .activated {
            do {
                try session.updateApplicationContext(data)
            } catch {
                statusText = "PING FAILED"
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            self.statusText = "PING SUCCESSFUL"
            self.didStatusChange = true
        }
    }
    
}
