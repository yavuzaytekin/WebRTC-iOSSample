//
//  WebRTCClient.swift
//  WebRTC-iOSSample
//
//  Created by Yavuz Aytekin on 29.04.2023.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func peerConnection(didGenerate candidate: IceCandidate)
}

protocol WebRTCClientProtocol {
    var delegate: WebRTCClientDelegate? { get set }
    func offer(completion: @escaping (_ sdp: SessionDescription) -> Void)
    func answer(completion: @escaping(_ sdp: SessionDescription) -> Void)
    func setRemoteSDP(with sessionDescription: SessionDescription, completion: @escaping (Error?) -> ())
    func setRemoteCandidate(with remoteCandidate: IceCandidate, completion: @escaping (Error?) -> ())
}

final class WebRTCClient: NSObject {
    private var peerConnection: RTCPeerConnection?
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private static let factory: RTCPeerConnectionFactory = {
        return RTCPeerConnectionFactory()
    }()
    
    weak var delegate: WebRTCClientDelegate?
    
    override init() {
        super.init()
        configurePeerConnection()
        addAudioTrack()
    }
    
    private func configurePeerConnection() {
        let configuration = RTCConfiguration()
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        self.peerConnection = WebRTCClient.factory.peerConnection(with: configuration, constraints: constraints, delegate: self)
    }
    
    private func addAudioTrack() {
        let streamId = "audioStream"
        let audioTrack = createAudioTrack()
        peerConnection?.add(audioTrack, streamIds: [streamId])
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: constraints)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio")
        return audioTrack
    }
    
    private func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
    }
}

//MARK: - WebRTCClientProtocol
extension WebRTCClient: WebRTCClientProtocol {
    func offer(completion: @escaping (_ sdp: SessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection?.offer(for: constrains, completionHandler: { sdp, error in
            guard let sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                guard error == nil else { return }
                let sessionDescription = SessionDescription(from: sdp)
                completion(sessionDescription)
            })
        })
    }
    
    func answer(completion: @escaping(_ sdp: SessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection?.answer(for: constrains, completionHandler: { sdp, error in
            guard let sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                guard error == nil else { return }
                let sessionDescription = SessionDescription(from: sdp)
                completion(sessionDescription)
            })
        })
    }
    
    func setRemoteSDP(with sessionDescription: SessionDescription, completion: @escaping (Error?) -> ()) {
        let rtcSessionDescription = sessionDescription.getRTCSessionDescription()
        peerConnection?.setRemoteDescription(rtcSessionDescription, completionHandler: completion)
    }
    
    func setRemoteCandidate(with remoteCandidate: IceCandidate, completion: @escaping (Error?) -> ()) {
        let candidate = remoteCandidate.getRTCIceCandidate()
        self.peerConnection?.add(candidate, completionHandler: completion)
    }
}

//MARK: - RTCPeerConnectionDelegate
extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("WebRTCClient didChange stateChanged: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("WebRTCClient didAdd stream: \(stream)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("WebRTCClient didRemove stream: \(stream)")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("WebRTCClient peerConnectionShouldNegotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("WebRTCClient didChange newState: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("WebRTCClient didChange newState: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        debugPrint("peerConnection didGenerate candidate: \(candidate)")
        let iceCandidate = IceCandidate(from: candidate)
        delegate?.peerConnection(didGenerate: iceCandidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("WebRTCClient didRemove candidates: \(candidates)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("WebRTCClient didOpen dataChannel: \(dataChannel)")
    }
}
