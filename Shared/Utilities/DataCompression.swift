import Foundation
import Compression

/// Errors that can occur while compressing or decompressing `Data` values.

enum DataCompressionError: Error {
    case compressionFailed
    case decompressionFailed
}

extension Data {
    /// Returns a compressed representation of the data using the specified
    /// algorithm. The output buffer grows automatically if the initial
    /// capacity is insufficient.
    func compressed(using algorithm: compression_algorithm) throws -> Data {
        guard !isEmpty else { return self }

        return try withUnsafeBytes { (srcBuffer: UnsafeRawBufferPointer) -> Data in
            guard let srcPtr = srcBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw DataCompressionError.compressionFailed
            }

            var dstSize = Swift.max(count, 64)
            var dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
            var outputSize = compression_encode_buffer(
                dstBuffer,
                dstSize,
                srcPtr,
                count,
                nil,
                algorithm
            )

            while outputSize == 0 {
                dstBuffer.deallocate()
                dstSize *= 2
                dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
                outputSize = compression_encode_buffer(
                    dstBuffer,
                    dstSize,
                    srcPtr,
                    count,
                    nil,
                    algorithm
                )
            }

            guard outputSize != 0 else {
                dstBuffer.deallocate()
                throw DataCompressionError.compressionFailed
            }

            let data = Data(bytes: dstBuffer, count: outputSize)
            dstBuffer.deallocate()
            return data
        }
    }

    /// Decompresses the data using the supplied algorithm.
    func decompressed(using algorithm: compression_algorithm) throws -> Data {
        guard !isEmpty else { return self }

        return try withUnsafeBytes { (srcBuffer: UnsafeRawBufferPointer) -> Data in
            guard let srcPtr = srcBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw DataCompressionError.decompressionFailed
            }

            var dstSize = count * 4
            var dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
            var outputSize = compression_decode_buffer(
                dstBuffer,
                dstSize,
                srcPtr,
                count,
                nil,
                algorithm
            )

            while outputSize == 0 {
                dstBuffer.deallocate()
                dstSize *= 2
                dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
                outputSize = compression_decode_buffer(
                    dstBuffer,
                    dstSize,
                    srcPtr,
                    count,
                    nil,
                    algorithm
                )
            }

            guard outputSize != 0 else {
                dstBuffer.deallocate()
                throw DataCompressionError.decompressionFailed
            }

            let data = Data(bytes: dstBuffer, count: outputSize)
            dstBuffer.deallocate()
            return data

        }
    }
}

