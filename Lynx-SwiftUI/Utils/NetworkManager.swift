//
//  NetworkManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation
import SystemConfiguration

class NetworkManager {
    static let shared = NetworkManager()
    
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com")
    
    func isInternetAvailable() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }

}
