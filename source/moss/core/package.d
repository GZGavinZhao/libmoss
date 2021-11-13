/*
 * This file is part of moss-core.
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

module moss.core;

import core.stdc.stdlib : EXIT_FAILURE, EXIT_SUCCESS;

public import moss.core.encoding;
public import moss.core.util;
public import moss.core.platform;
public import moss.core.store;

public import std.stdint : uint8_t;

/** Current Moss Version */
const Version = "0.0.1";

public import moss.core.platform;

/**
 * Currently just wraps the two well known exit codes from the
 * C standard library. We will flesh this out with specific exit
 * codes to facilitate integration with scripts and tooling.
 */
enum ExitStatus
{
    Failure = EXIT_FAILURE,
    Success = EXIT_SUCCESS,
}

/**
 * Base of all our required directories
 */
const RootTree = "os";

/**
 * The HashStore directory, used for deduplication purposes
 */
const HashStore = RootTree ~ "/store";

/**
 * The RootStore directory contains our OS image root
 */
const RootStore = RootTree ~ "/root";

/**
 * The DownloadStore directory contains all downloads
 */
const DownloadStore = RootTree ~ "/download";

/**
 * Well known file type
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
