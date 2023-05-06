//
//  SocketMessage.swift
//  WebRTC-iOSSample
//
//  Created by Yavuz Aytekin on 29.04.2023.
//

import Foundation

enum SocketMessage: Codable {
    case sdp(SessionDescription)
    case candidate(IceCandidate)

    static func generateMessageData(from candidate: IceCandidate) -> Data {
        try! JSONEncoder().encode(SocketMessage.candidate(candidate))
    }
    
    static func generateMessageData(from sdp: SessionDescription) -> Data {
        
        try! JSONEncoder().encode(SocketMessage.sdp(sdp))
    }

    static func decodeSocketMessage(from data: Data) -> SocketMessage {
        try! JSONDecoder().decode(SocketMessage.self, from: data)
    }
}
