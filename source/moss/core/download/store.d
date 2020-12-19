/*
 * This file is part of moss-core.
 *
 * Copyright © 2020 Serpent OS Developers
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

module moss.core.download.store;

public import moss.core.store;

/**
 * The DownloadStore is a specialist implementation of the DiskStore
 * used for downloading + fetching files.
 */
final class DownloadStore : DiskStore
{

    @disable this();

    this(StoreType type)
    {
        super(type, "downloads", "v1");
    }

    /**
     * Specialised handler for full paths
     */
    override string fullPath(const(string) name)
    {
        import std.path : buildPath;

        if (name.length > 10)
        {
            return directory.buildPath(name[0 .. 5], name[$ - 5 .. $], name);
        }
        return super.fullPath(name);
    }
}
