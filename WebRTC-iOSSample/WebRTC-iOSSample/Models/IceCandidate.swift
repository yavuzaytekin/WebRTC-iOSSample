//
//  IceCandidate.swift
//  WebRTC-iOSSample
//
//  Created by Yavuz Aytekin on 29.04.2023.
//

import Foundation
import WebRTC

struct IceCandidate: Codable {
    var sdpMid: String?
    var sdpMLineIndex: Int32
    var sdp: String
    
    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMid = iceCandidate.sdpMid
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdp = iceCandidate.sdp
    }
    
    func getRTCIceCandidate() -> RTCIceCandidate {
        RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
