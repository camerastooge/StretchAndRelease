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
	var statusContext: [String: Any] = ["stretch" : 0, "rest" : 0, "reps" : 0, "playlist" : false]
    
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
		if activationState == .activated {
			print("phone connection established")
		} else {
			print("phone connection failed")
		}
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    #else
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if activationState == .activated {
			print("watch connection established")
		} else {
			print("watch connection failed")
		}
    }
    
    #endif
    
    func setContext(to data: [String : Any]) {
        let session = WCSession.default
        if session.activationState == .activated {
            do {
                try session.updateApplicationContext(data)
				print("context function fired \(Date.now.formatted(date: .omitted, time: .shortened))")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            self.statusText = "CS \(Date.now.formatted(date: .omitted, time: .shortened))"
            self.statusContext = applicationContext
            self.didStatusChange = true
			print(self.statusText)
        }
    }
    
}
