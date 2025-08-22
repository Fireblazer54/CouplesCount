import Foundation
import Compression

enum DataCompressionError: Error {
    case compressionFailed
    case decompressionFailed
}

extension Data {
    func compressed(using algorithm: compression_algorithm) throws -> Data {
        try perform(operation: COMPRESSION_STREAM_ENCODE, algorithm: algorithm)
    }

    func decompressed(using algorithm: compression_algorithm) throws -> Data {
        try perform(operation: COMPRESSION_STREAM_DECODE, algorithm: algorithm)
    }

    private func perform(operation: compression_stream_operation, algorithm: compression_algorithm) throws -> Data {
        guard !isEmpty else { return self }

        var stream = compression_stream()
        var status = compression_stream_init(&stream, operation, algorithm)
        guard status != COMPRESSION_STATUS_ERROR else {
            throw operation == COMPRESSION_STREAM_ENCODE ? DataCompressionError.compressionFailed : DataCompressionError.decompressionFailed
        }
        defer { compression_stream_destroy(&stream) }

        let bufferSize = Swift.max(count, 64 * 1024)
        let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { dstBuffer.deallocate() }

        var output = Data()

        return try withUnsafeBytes { (srcBuffer: UnsafeRawBufferPointer) -> Data in
            guard let srcPointer = srcBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw operation == COMPRESSION_STREAM_ENCODE ? DataCompressionError.compressionFailed : DataCompressionError.decompressionFailed
            }

            stream.src_ptr = srcPointer
            stream.src_size = count
            stream.dst_ptr = dstBuffer
            stream.dst_size = bufferSize

            let flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)

            repeat {
                status = compression_stream_process(&stream, flags)
                switch status {
                case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                    let produced = bufferSize - stream.dst_size
                    if produced > 0 {
                        output.append(dstBuffer, count: produced)
                    }
                    stream.dst_ptr = dstBuffer
                    stream.dst_size = bufferSize
                default:
                    throw operation == COMPRESSION_STREAM_ENCODE ? DataCompressionError.compressionFailed : DataCompressionError.decompressionFailed
                }
            } while status == COMPRESSION_STATUS_OK

            if status == COMPRESSION_STATUS_END {
                return output
            } else {
                throw operation == COMPRESSION_STREAM_ENCODE ? DataCompressionError.compressionFailed : DataCompressionError.decompressionFailed
            }
        }
    }
}

