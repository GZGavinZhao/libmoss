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

module moss.format.binary;

public import std.stdint : uint32_t;

public import moss.format.binary.archive_header;
public import moss.format.binary.endianness;
public import moss.format.binary.payload;
public import moss.format.binary.reader;
public import moss.format.binary.writer;

/**
 * Current version of the package format that we target.
 */
const uint32_t mossFormatVersionNumber = 1;

/**
 * A FileType is a simple tagging mechanism so that we're able to record the
 * destination file type (*Nix) in the layout, so that it may be reapplied
 * upon extraction.
 */
enum FileType : uint8_t
{
    /* Catch errors */
    Unknown = 0,

    /** Regular file **/
    Regular = 1,

    /** Symbolic link to another location */
    Symlink = 2,

    /** Directory */
    Directory = 3,

    /** Character Device */
    CharacterDevice = 4,

    /** Block device */
    BlockDevice = 5,

    /** Fifo pipe */
    Fifo = 6,

    /** Socket */
    Socket = 7,
}
