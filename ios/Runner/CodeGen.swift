import CommonCrypto
import Foundation

private let codeVerifierKey: String = "com.bravedefault.codeVerifier"

extension String {
    func sha256()->Data {
        guard let data = self.data(using: .utf8) else {
            fatalError("data initialize is failed")
        }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
}

public class CodeGen {
    /// code verifier 是一个长度位43到128位的随机字符串
    /// - Parameter length: pixiv的长度是43，因此默认长度是43
    public static func getCodeVer(_ length:Int = 43)->String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString:String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            let index = base.index(base.startIndex, offsetBy: Int(randomValue))
            randomString += "\(base[index])"
        }
        return randomString
    }

    public static func getCodeChallenge(codeVerifier: String)->String {
        return "not need"
    }
    
    public static func updateCodeVerifier(codeVerifier: String) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(codeVerifier, forKey: codeVerifierKey)
    }
    
    public static func getLocalCodeVerifier()->String? {
        return UserDefaults.standard.string(forKey: codeVerifierKey)
    }
}
