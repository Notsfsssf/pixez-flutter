//
//  Utils.swift
//  PixivHelper
//
//  Created by Zeyong Zhou on 2020/12/7.
//

import Foundation

fileprivate let base64URLDigits = [UInt8]("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8)

fileprivate let base64URLDecodingIndex: [UInt8] = {
    // 64 is used as an error marker since 0 is a valid value
    var decoded = [UInt8](repeating: 64, count: 256)
    for (value, digit) in base64URLDigits.enumerated() {
        decoded[Int(digit)] = UInt8(value)
    }
    return decoded
}()

public extension Data {

    /// Creates a new data buffer from a base-64 URL encoded `String` using `options`.
    init?(base64URLEncoded string: String, options: Base64DecodingOptions = []) {
        guard let encoded = string.data(using: .utf8) else { return nil }
        guard let decoded = encoded.base64URLDecodedData() else { return nil }
        self = decoded
    }

    /// Returns the contents base-64 URL encoded.
    func base64URLEncodedData() -> Data {
        let length = count
        let padding = (3 - (length % 3)) % 3 // the would-be amount of padding, for calculations
        let encodedLength = 4 * ((length + padding) / 3) - padding

        var encoded = Data(count: encodedLength)
        var outputIndex = 0

        var inputIndex = 0
        while inputIndex + 3 <= length { // 3 bytes of data -> 4 characters encoded
            let byte1 = Int(self[inputIndex])
            let byte2 = Int(self[inputIndex + 1])
            let byte3 = Int(self[inputIndex + 2])
            inputIndex += 3
            encoded[outputIndex]     = base64URLDigits[byte1 >> 2]
            encoded[outputIndex + 1] = base64URLDigits[((byte1 & 0x03) << 4) | (byte2 >> 4)]
            encoded[outputIndex + 2] = base64URLDigits[((byte2 & 0x0F) << 2) | (byte3 >> 6)]
            encoded[outputIndex + 3] = base64URLDigits[byte3 & 0x3F]
            outputIndex += 4
        }

        if padding != 0 { // byte count was not divisible by 3
            let byte1 = Int(self[inputIndex])
            let byte2 = (padding == 1) ? Int(self[inputIndex + 1]) : 0

            encoded[outputIndex] = base64URLDigits[byte1 >> 2]
            encoded[outputIndex + 1] = base64URLDigits[((byte1 & 0x03) << 4) | (byte2 >> 4)]
            if padding == 1 {
                encoded[outputIndex + 2] = base64URLDigits[(byte2 & 0x0F) << 2]
            }
        }

        return encoded
    }

    /// Returns the contents base-64 URL encoded into a string.
    func base64URLEncodedString() -> String {
        return String(data: base64URLEncodedData(), encoding: .utf8)!
    }

    /// Interprets the contents of this as base-64 URL encoded and
    /// returns the decoded data.
    func base64URLDecodedData(options: Data.Base64DecodingOptions = []) -> Data? {
        let encoded: Data = {
            if options.contains(.ignoreUnknownCharacters) && !self.isEmpty {
                return filter { byte in base64URLDecodingIndex[Int(byte)] != 64 }
            } else {
                return self
            }
        }()

        let length = encoded.count
        guard length != 0 else { return Data() }

        let trailingBytes: Int = {
            let trailingEncoded = length % 4
            return trailingEncoded == 0 ? 0 : trailingEncoded - 1
        }()
        let decodedLength = (length / 4) * 3 + trailingBytes
        var decoded = Data(count: decodedLength)

        var i = 0
        var outputIndex = 0
        var errorCheck = 0

        let decodeNextByte: () -> Int = {
            let byte = Int(base64URLDecodingIndex[Int(encoded[i])])
            i += 1
            errorCheck |= byte
            return byte
        }

        while i + 4 <= length { // decode 4 characters to 3 bytes
            var value = decodeNextByte() << 18
            value |= decodeNextByte() << 12
            value |= decodeNextByte() << 6
            value |= decodeNextByte()

            decoded[outputIndex] = UInt8(truncatingIfNeeded: value >> 16)
            outputIndex += 1
            decoded[outputIndex] = UInt8(truncatingIfNeeded: value >> 8)
            outputIndex += 1
            decoded[outputIndex] = UInt8(truncatingIfNeeded: value)
            outputIndex += 1
        }

        if trailingBytes != 0 { // decode the last 2 or 3 characters
            var value = decodeNextByte() << 12
            value |= decodeNextByte() << 6

            decoded[outputIndex] = UInt8(truncatingIfNeeded: value >> 10)
            if trailingBytes != 1 {
                outputIndex += 1
                value |= decodeNextByte()
                decoded[outputIndex] = UInt8(truncatingIfNeeded: value >> 2)
            }
        }

        guard errorCheck & 0xC0 == 0 else { return nil }

        return decoded
    }

    /// Encodes the contents to `encoder` as a single string value
    /// using base-64 URL encoding.
    func base64URLEncode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base64URLEncodedString())
    }

}

public extension String {

    /// Returns the contents of this string base-64 URL encoded.
    func base64URLEncoded(using encoding: String.Encoding = .utf8) -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.base64URLEncodedString()
    }

    /// Interprets the contents of this string as base-64 URL encoded and
    /// returns the decoded data.
    func base64URLDecodedData(options: Data.Base64DecodingOptions = []) -> Data? {
        guard let encoded = data(using: .utf8) else { return nil }
        return encoded.base64URLDecodedData(options: options)
    }

    /// Interprets the contents of this string as base-64 URL encoded and
    /// returns the decoded data as a string using `encoding`.
    func base64URLDecodedString(using encoding: String.Encoding = .utf8, options: Data.Base64DecodingOptions = []) -> String? {
        guard let data = base64URLDecodedData(options: options) else { return nil }
        return String(data: data, encoding: encoding)
    }

}

/// A closure suitable for the `custom` `dataEncodingStrategy` of `JSONEncoder`.
public let base64URLDataEncoding: (Data, Encoder) throws -> Void = { data, encoder in
    try data.base64URLEncode(to: encoder)
}

/// A closure suitable for the `custom` `dataDecodingStrategy` of `JSONDecoder`.
public let base64URLDataDecoding: (Decoder) throws -> Data = { decoder in
    var container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let data = string.base64URLDecodedData() else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Data not base 64 URL encoded")
    }
    return data
}
