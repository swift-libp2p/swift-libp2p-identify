import XCTest
import LibP2P
@testable import LibP2PIdentify

final class LibP2PIdentifyTests: XCTestCase {
    func testIPFSIdentifyPushPayloadJSClient() throws {
        /// An example /ipfs/id/push/1.0.0 payload from a JS Client
        let payloadString = "a7061208047f00000106c223120804c0a8011706c223120804c0a8011606c2231208044caa3c850688fc1208044caa3c850686601a1b2f6c69627032702f636972637569742f72656c61792f302e312e301a0e2f697066732f69642f312e302e301a132f697066732f69642f707573682f312e302e301a102f697066732f70696e672f312e302e30429e050aab02080012a60230820122300d06092a864886f70d01010105000382010f003082010a02820101009a3520ce8cfcfa4fc1d9b1fecb0e9c6241188dd8e8dec881d44b4e69f1058eaf710550216c0b7d51e26a22844e4737e17135a954cb215953fff28dfd6976794c26aad507225231afb2db2e31d85b9ca680803bded3c7e896cf0959d945c451733563cd6684f6de597cbec0fdb11254e02044744ec9ffb61a00d120f6bbdc09b95bccedd07b701707626a95e891fe29609e7514ee9ba3b506cb2a3ffe0b6e6dbeae4adb678fa8551a14d8344ba0584aab0a8bb7296b6ee8f85ce2375f290c5d5e7eb905f3d49cee6cd381f65b1ce8af9e442fb0f218610ee14c833919e2aa260a7c77ba13baeca68809df32aaa05ae8f27ff9f04ce57938863c91e346f071fe350203010001120203011a670a221220add8ac59b1fe19f20dfaa2228c239e3c131d73e0a7848ac869d5eb959a27ec6c10a5d9c6f28b301a0a0a08047f00000106c2231a0a0a0804c0a8011706c2231a0a0a0804c0a8011606c2231a0a0a08044caa3c850688fc1a0a0a08044caa3c850686602a800228a3216af2fd7701d4cc0014d5fc410a8423a21170b2784516d7740405c7bf903cd7ed837725e857680c0cb0dbaf6fc4f95d7fe692872f16417e8fcfaad3cdd3b529e8fb224ba3a0cabdc36bee1f77ab013aa35beae0e46c4bf4e438ffad4a2fa558b43323a2526547bb47935ea1f3ea9fa67dc8bd51160f4a9875717ec146f0ef293cd4892e0395b042e6e7f0fd0af9babb06e1527ee0f11b50671d7a190877d354abe11e32c607c7492598b37a29c35925c43b89f5a4e92e97b1973ecaa1027714e2439ffe27b390e31d4763d6b5fe637c95848e8832f1bb7ec4de20ee9b767286661a8d0aeeedf5cdb97e639fa530b237a2914459e173fb2aad3363d8bb08"
        
        let payload = Array<UInt8>(hex: payloadString)
        
        let lengthPrefix = uVarInt(payload)
        
        let identifyProto = try? IdentifyMessage(contiguousBytes: payload.dropFirst(lengthPrefix.bytesRead))
        
        XCTAssertNotNil(identifyProto)
        
        for addy in identifyProto!.listenAddrs {
            print(try Multiaddr(addy))
        }
        XCTAssertEqual(identifyProto?.listenAddrs.count, 5)
        
        for proto in identifyProto!.protocols {
            print(proto)
        }
        XCTAssertEqual(identifyProto?.protocols.count, 4)
        
        // Try and decode the Sealed Envelope containing the Signed PeerRecord
        // We should use the public key that we have on file to verify the signedEnvelope
        guard let signedEnvelope = try? SealedEnvelope(marshaledEnvelope: identifyProto!.signedPeerRecord.bytes, verifiedWithPublicKey: nil) else {
            XCTFail("Identify::Failed to decode Envelope containing PeerRecord")
            return
        }
        print("\n\(signedEnvelope)")

        // Try and decode the PeerRecord (passing in the publicKey data so we get a pubkey PeerID, instead of an idOnly PeerID)
        guard let peerRecord = try? PeerRecord(marshaledData: Data(signedEnvelope.rawPayload)) else {
            XCTFail("Identify::Failed to decode Peer Record")
            return
        }
        
        print(peerRecord)
        
        XCTAssertEqual(peerRecord.peerID.b58String, "Qma3GsJmB47xYuyahPZPSadh1avvxfyYQwk8R3UnFrQ6aP")
    }
}
