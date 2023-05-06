//
//  SessionDescription.swift
//  WebRTC-iOSSample
//
//  Created by Yavuz Aytekin on 29.04.2023.
//

import Foundation
import WebRTC

struct SessionDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case type, sdp
    }
    
    var type: RTCSdpType
    var sdp: String
    
    init(type: RTCSdpType, sdp: String) {
        self.type = type
        self.sdp = sdp
    }
    
    init(from rtcSDP: RTCSessionDescription) {
        self.type = rtcSDP.type
        self.sdp = rtcSDP.sdp
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let sdp = try values.decode(String.self, forKey: .sdp)
        let type = try values.decode(Int.self, forKey: .type)
        
        self.sdp = sdp
        self.type = RTCSdpType(rawValue: type) ?? .rollback
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(sdp, forKey: .sdp)
    }
    
    func getRTCSessionDescription() -> RTCSessionDescription {
        RTCSessionDescription(type: type, sdp: sdp)
    }
}
