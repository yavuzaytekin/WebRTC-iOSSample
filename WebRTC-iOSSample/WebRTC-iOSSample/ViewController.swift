//
//  ViewController.swift
//  WebRTC-iOSSample
//
//  Created by Yavuz Aytekin on 29.04.2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var socketStatusLabel: UILabel!
    @IBOutlet weak var localSDPLabel: UILabel!
    @IBOutlet weak var remoteSDPLabel: UILabel!
    
    var socket: SocketClientProtocol?
    var webRTCClient: WebRTCClientProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSocket()
        configureWebRTCClient()
    }
    
    func configureSocket() {
        socket = SocketClient()
        socket?.delegate = self
    }
    
    func configureWebRTCClient() {
        webRTCClient = WebRTCClient()
        webRTCClient?.delegate = self
    }
    
    @IBAction func sendOffer(_ sender: Any) {
        debugPrint("sendOffer")
        webRTCClient?.offer(completion: { sdp in
            let data = SocketMessage.generateMessageData(from: sdp)
            self.socket?.send(data: data)
            DispatchQueue.main.async {
                self.localSDPLabel.text = "Local SDP : 🟢"
            }
            
            debugPrint("Offer sdp: \(sdp)")
        })
    }
    
    @IBAction func sendAnswer(_ sender: Any) {
        debugPrint("sendAnswer")
        webRTCClient?.answer(completion: { sdp in
            let data = SocketMessage.generateMessageData(from: sdp)
            self.socket?.send(data: data)
            DispatchQueue.main.async {
                self.localSDPLabel.text = "Local SDP : 🟢"
            }
        })
    }
    
    private func changeSocketStatus(with status: SocketStatus) {
        var socketStatusText = "Socket Status: "
        switch status {
        case .connected:
            socketStatusText.append("🟢")
        case .disconnected:
            socketStatusText.append("🔴")
        }
        DispatchQueue.main.async {
            self.socketStatusLabel.text = socketStatusText
        }
    }
}

// MARK: - SocketClientDelegate
extension ViewController: SocketClientDelegate {
    func changedSocketStatus(with status: SocketStatus) {
        changeSocketStatus(with: status)
    }
    
    func handleSocketMessage(with message: SocketMessage) {
        switch message {
        case .sdp(let sdp):
            webRTCClient?.setRemoteSDP(with: sdp, completion: { err in
                guard err == nil else { return }
                DispatchQueue.main.async {
                    self.remoteSDPLabel.text = "Remote SDP : 🟢"
                }
            })
        case .candidate(let candidate):
            webRTCClient?.setRemoteCandidate(with: candidate, completion: { err in
                guard err == nil else { return }
                debugPrint("Remote candidate added: \(candidate)")
            })
        }
    }
}

// MARK: - WebRTCClientDelegate
extension ViewController: WebRTCClientDelegate {
    func peerConnection(didGenerate candidate: IceCandidate) {
        let data = SocketMessage.generateMessageData(from: candidate)
        socket?.send(data: data)
    }
}
