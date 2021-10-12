/*
 * This file is part of moss-deps.
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

module moss.deps.query.source;

public import moss.deps.query.candidate;

/**
 * When querying we can lookup by name, ID, etc.
 */
enum ProviderType
{
    PackageName,
    PackageID,
}

/**
 * A QuerySource is added to the QueryManager allowing it to load data from pkgIDs
 * if present.
 */
public interface QuerySource
{
    /**
     * The QuerySource will be given a callback to execute if it finds any
     * matching providers for the input string and type
     */
    const(PackageCandidate)[] queryProviders(in ProviderType type, in string matcher);
}
