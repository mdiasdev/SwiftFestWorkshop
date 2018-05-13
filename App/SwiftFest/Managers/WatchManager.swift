//
//  WatchManager.swift
//  SwiftFest
//
//  Created by Matthew Dias on 5/13/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchManager: NSObject {
    static let main = WatchManager()

    func isSupported() -> Bool {
        guard WCSession.default.activationState != .activated else { return true }

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            return true
        }

        return false
    }

    func send(json: [String: Any]) {
        if WCSession.default.activationState == .activated && WCSession.default.isReachable {
            WCSession.default.sendMessage(json, replyHandler: nil)
        }
    }
}

extension WatchManager: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("App: activationDidCompleteWith")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("App: sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("App: sessionDidDeactivate")
    }
}
