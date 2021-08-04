//
//  NetworkMonitor.swift
//  Flan
//
//  Created by Вадим on 17.07.2021.
//

import Network
import UIKit

// MARK: - Protocol

protocol NetworkCheckObserver: AnyObject {
    func statusDidChange(status: NWPath.Status)
}

class NetworkCheck {

    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }
    
    // MARK: - Props

    private var monitor = NWPathMonitor()
    private static let _sharedInstance = NetworkCheck()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }

    class func sharedInstance() -> NetworkCheck {
        return _sharedInstance
    }
    
    // MARK: - Initialization

    private init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {

                //If any observer is nil, remove it from the list of observers
                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }

                DispatchQueue.main.async(execute: {
                    observer.statusDidChange(status: path.status)
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    // MARK: - Funcs

    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }

    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
