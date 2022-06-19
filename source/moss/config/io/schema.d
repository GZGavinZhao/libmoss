/* SPDX-License-Identifier: Zlib */

/**
 * moss.config.io.schema
 *
 * Various schemas useful for moss configuration purposes
 *
 * Authors: © 2020-2022 Serpent OS Developers
 * License: Zlib
 */
module moss.config.io.schema;

/**
 * To simplify internal type unmarshalling we have our own basic
 * types of yaml keys
 */
enum YamlType
{
    Single = 0,
    Array = 1,
    Map = 2,
}

/**
 * Assign the domain automatically during struct creation
 */
public struct ConfigurationDomain
{
    string applicationIdentity = null;
    string domain = null;
}

/**
 * UDA to help unmarshall the correct values.
 */
struct YamlSchema
{
    /** Name of the YAML key */
    string name;

    /** Is this a mandatory key? */
    bool required = false;

    /** Type of value to expect */
    YamlType type = YamlType.Single;

    /** If set, these are the acceptable string values */
    string[] acceptableValues;
}
