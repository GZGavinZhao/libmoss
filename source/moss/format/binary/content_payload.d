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

module moss.format.binary.content_payload;

import moss.format.binary.endianness;
import moss.format.binary.payload;

public import std.stdio : File, FILE;

/**
 * Shared between implementations, the currently supported version for
 * the ContentPayload
 */
const uint16_t contentPayloadVersion = 1;

/**
 * The ContentPayload contains concatenated data that may or may not
 * be compressed. It is one very large blob, and does not much else.
 */
struct ContentPayload
{

public:

    /** Extend base Payload type with ContentPayload specifics */
    Payload pt;
    alias pt this;

    /**
     * Ensure default initialisation is not insane.
     */
    static ContentPayload opCall()
    {
        ContentPayload r;
        r.type = PayloadType.Content;
        r.compression = PayloadCompression.None;
        r.payloadVersion = contentPayloadVersion;
        r.length = 0;
        r.size = 0;
        r.numRecords = 0;
        return r;
    }

    /**
     * Encode our data to the archive
     */
    void encode(File file)
    {
        import std.exception : enforce;

        scope FILE* fp = file.getFP();

        Payload us = this;

        auto startPoint = file.tell();
        us.toNetworkOrder();
        us.encode(fp);
        us.toHostOrder();

        import std.stdio : seek, flush;

        switch (us.compression)
        {
        case PayloadCompression.None:
            encodeNoCompression(fp);
            break;
        case PayloadCompression.Zstd:
            encodeZstdCompression(fp);
            break;
        default:
            assert(0, "ContentPayload.encode: Unsupported compression");
        }

        file.flush();

        us = this;

        /* Go back and update the payload */
        file.seek(startPoint, SEEK_SET);
        us.toNetworkOrder();
        us.encode(fp);

        /* Back to the end */
        file.seek(length, SEEK_CUR);
        file.flush();
    }

    /**
     * Write all data with no compression
     */
    void encodeNoCompression(scope FILE* fp)
    {
        import std.stdio : fwrite;
        import std.digest.crc : CRC64ISO;

        const auto ChunkSize = 16 * 1024 * 1024;
        CRC64ISO hash;

        ulong written = 0;

        /* Now read and copy each file into the archive */
        foreach (k; order)
        {
            auto v = content[k];

            /* Open in binary read */
            File input = File(v, "rb");
            foreach (ubyte[] buffer; input.byChunk(ChunkSize))
            {
                fwrite(buffer.ptr, buffer[0].sizeof, buffer.length, fp);
                hash.put(buffer);
                written += buffer.length;
            }
        }
        crc64 = hash.finish();

        length = written;
        size = written;
    }

    /**
     * Write all data with ZSTD compression
     */
    void encodeZstdCompression(scope FILE* fp)
    {
        import std.stdio : fwrite;
        import std.digest.crc : CRC64ISO;
        import zstd : Compressor;

        ulong compSize = 0;
        ulong normSize = 0;
        CRC64ISO hash;

        /* TODO: Get rid of this class and make our helper  */
        auto comp = new Compressor(8);

        foreach (k; order)
        {
            auto v = content[k];

            File input = File(v, "rb");
            foreach (ubyte[] buffer; input.byChunk(Compressor.recommendedInSize))
            {
                auto comped = comp.compress(buffer);
                normSize += buffer.length;
                compSize += comped.length;
                hash.put(comped);
                fwrite(comped.ptr, comped[0].sizeof, comped.length, fp);
            }

            auto flushed = comp.flush();
            if (flushed.length > 0)
            {
                compSize += flushed.length;
                hash.put(flushed);
                fwrite(flushed.ptr, flushed[0].sizeof, flushed.length, fp);
            }
        }

        crc64 = hash.finish();
        length = compSize;
        size = normSize;
    }

    /**
     * Add a file to the content payload. It will not be loaded or
     * written until the archive is being flushed.
     */
    void addFile(string hashID, string sourcePath)
    {
        assert(!(hashID in content), "addFile(): must be a unique hash");
        content[hashID] = sourcePath;
        order ~= hashID;
        numRecords++;
    }

    /**
     * Return true if we have the file
     */
    pure bool hasFile(string hashID) @safe @nogc nothrow
    {
        if (hashID in content)
        {
            return true;
        }
        return false;
    }

private:

    string[string] content;
    string[] order;
}
