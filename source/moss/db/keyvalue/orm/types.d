/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * moss.db.keyvalue.orm.types
 *
 * Base types/decorators for the ORM system
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module moss.db.keyvalue.orm.types;

import std.traits;
import moss.core.encoding;

/**
 * UDA: Decorate a field as the primary key in a model
 */
struct PrimaryKey
{
    /**
     * Automatically increment for each key insertion.
     * Requires an integer type
     */
    bool autoIncrement;
}

/**
 * UDA: Construct a two-way mapping for quick indexing
 */
struct Indexed
{
}

/**
 * UDA: Marks a model as consumable.
 */
struct Model
{
    /**
     * Override the table name
     */
    string name;
}

static bool hasModelDecorator(M)()
{
    static if (hasUDA!(M, Model))
    {
        return true;
    }
    else
    {
        return false;
    }
}
/**
 * Return true if a primary key was found.
 *
 * Params:
 *      M = Model to validate
 * Returns: true if model valid
 */
static bool hasPrimaryKey(M)()
{
    static if (getSymbolsByUDA!(M, PrimaryKey).length != 1)
    {
        return false;
    }
    else
    {
        return true;
    }
}

/**
 * Allow runtime/compile time checking
 *
 * Params:
 *      M = Model to validate
 * Returns: true if model valid
 */
static bool isValidModel(M)()
        if (hasModelDecorator!M && hasPrimaryKey!M && isEncodable!M && __traits(isPOD, M))
{
    return true;
}

/**
 * Return true if we can encode this type
 *
 * Params:
 *      M = Model to validate
 * Returns: true if model valid
 */
static bool isEncodable(M)()
{
    bool ret = true;
    static foreach (field; __traits(allMembers, M))
    {
        {
            alias fieldType = OriginalType!(typeof(__traits(getMember, M, field)));
            static if (!isMossEncodable!fieldType)
            {
                /* Let the dev know why this doesn't work */
                pragma(msg,
                        M.stringof ~ "." ~ field ~ ": Type (" ~ fieldType.stringof
                        ~ ") is not mossEncodable");
                ret = false;
            }
        }
    }
    return ret;
}

/**
 * Return the Model() for the Model type.
 */
private auto getModel(M)()
{
    static if (is(typeof(getUDAs!(M, Model)[0]) == Model))
    {
        return getUDAs!(M, Model)[0];
    }
    else
    {
        return Model();
    }
}

/**
 * Retrieve the model name (bucket name) for the model.
 *
 * Params:
 *      M = Model
 * Returns: Name to use for the model
 */
public static auto modelName(M)() @safe if (isValidModel!M)
{
    import std.string : toLower, endsWith;
    import std.range : empty;

    enum model = getModel!M;

    static if (!model.name.empty)
    {
        enum name = model.name;
    }
    else
    {
        enum name = M.stringof.toLower();
    }
    return name.endsWith("s") ? name : name ~ "s";
}
