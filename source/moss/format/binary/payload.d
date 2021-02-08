/*
 * This file is part of moss-format.
 *
 * Copyright © 2020-2021 Serpent OS Developers
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module moss.format.binary.payload;

public import std.stdint;
public import std.stdio : FILE;
import moss.format.binary.endianness;

/**
 * Specific payload type
 */
enum PayloadType : uint8_t
{
    /** Catch errors: Payload type should be known */
    Unknown = 0,

    /** The Metadata store */
    Meta = 1,

    /** File store, i.e. hash indexed */
    Content = 2,

    /** Map Files to Disk with basic UNIX permissions + types */
    Layout = 3,

    /** For indexing the deduplicated store */
    Index = 4,

    /* Attribute storage */
    Attributes = 5,
}

/**
 * A payload may optionally be compressed using some method like zstd.
 * It must be defined before the payload value is accessed. Additionally
 * the used compressionLevel must be stored to ensure third party tools
 * can reassemble the package.
 */
enum PayloadCompression : uint8_t
{
    /** Catch errors: Compression should be known */
    Unknown = 0,

    /** Payload has no compression */
    None = 1,

    /** Payload uses ZSTD compression */
    Zstd = 2,

    /** Payload uses zlib decompression */
    Zlib = 3,
}

/**
 * Payload is the root type within a moss binary package. Every payload
 * is expected to contain at least 1 record, with built-in verioning.
 */
extern (C) struct Payload
{
align(1):

    /** 8-bytes, endian aware, length of the Payload data */
    @AutoEndian uint64_t length = 0;

    /** 8-bytes, endian-aware, size of usable Payload data */
    @AutoEndian uint64_t size = 0;

    /** 8-byte array containing the CRC64-ISO checksum */
    ubyte[8] crc64 = 0; /* CRC64-ISO */

    /** 4-bytes, endian aware, number of records within the Payload */
    @AutoEndian uint32_t numRecords = 0;

    /** 2-bytes, endian aware, numeric version of the Payload */
    @AutoEndian uint16_t payloadVersion = 0;

    /** 1 byte denoting the type of this payload */
    PayloadType type = PayloadType.Unknown;

    /** 1 byte denoting the compression of this payload */
    PayloadCompression compression = PayloadCompression.Unknown;

    /**
     * Encode the Header to the underlying file stream
     */
    void encode(scope FILE* fp) @trusted
    {
        import std.stdio : fwrite;
        import std.exception : enforce;

        enforce(fwrite(&length, length.sizeof, 1, fp) == 1, "Failed to write Payload.length");
        enforce(fwrite(&size, size.sizeof, 1, fp) == 1, "Failed to write Payload.size");
        enforce(fwrite(crc64.ptr, crc64[0].sizeof, crc64.length,
                fp) == crc64.length, "Failed to write Payload.crc64");
        enforce(fwrite(&numRecords, numRecords.sizeof, 1, fp) == 1,
                "Failed to write Payload.numRecords");
        enforce(fwrite(&payloadVersion, payloadVersion.sizeof, 1, fp) == 1,
                "Failed to write Payload.payloadVersion");
        enforce(fwrite(&type, type.sizeof, 1, fp) == 1, "Failed to write Payload.type");
        enforce(fwrite(&compression, compression.sizeof, 1, fp) == 1,
                "Failed to write Payload.compression");
    }
}

static assert(Payload.sizeof == 32,
        "Payload size must be 16 bytes, not " ~ Payload.sizeof.stringof ~ " bytes");
