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

/**
 * Extra C bindings that moss requires
 */
module moss.core.ioutil;

import moss.core : KernelChunkSize;
import cstdlib = moss.core.c;
import std.sumtype;
public import std.conv : octal;
public import std.string : fromStringz, toStringz;

/**
 * Encapsulates errors from C functions
 */
public struct CError
{
    int errorCode = 0;

    /**
     * Return the display string for the error
     */
    @property const(char[]) toString() const
    {
        return fromStringz(cstdlib.strerror(errorCode));
    }
}

alias IOResult = SumType!(bool, CError);

/**
 * Forcibly namespace all of the operations to ensure no conflicts with the stdlib.
 */
public struct IOUtil
{
    /**
     * Copy the file fromPath into new file toPath, with optional mode (octal)
     */
    static IOResult copyFile(in string fromPath, in string toPath, cstdlib.mode_t mode = octal!644)
    {
        auto fdin = cstdlib.open(fromPath.toStringz, cstdlib.O_RDONLY | cstdlib.O_CLOEXEC, 0);
        if (fdin <= 0)
        {
            return IOResult(CError(cstdlib.errno));
        }
        auto fdout = cstdlib.open(toPath.toStringz,
                cstdlib.O_WRONLY | cstdlib.O_CREAT | cstdlib.O_TRUNC | cstdlib.O_CLOEXEC, mode);
        if (fdout <= 0)
        {
            return IOResult(CError(cstdlib.errno));
        }

        scope (exit)
        {
            cstdlib.close(fdin);
            cstdlib.close(fdout);
        }

        return copyFile(fdin, fdout);
    }

    /**
     * Directly copy from the input file descriptor to the output file descriptor
     */
    static IOResult copyFile(int fdIn, int fdOut)
    {
        cstdlib.loff_t nBytes = 0;
        do
        {
            nBytes = cstdlib.copy_file_range(fdIn, null, fdOut, null, KernelChunkSize, 0);
            if (nBytes < 0)
            {
                return IOResult(CError(cstdlib.errno));
            }
        }
        while (nBytes > 0);

        return IOResult(true);
    }

    /**
     * Sane mkdir wrapper that allows defining the creation mode.
     */
    static IOResult mkdir(in string path, cstdlib.mode_t mode = octal!755)
    {
        auto ret = cstdlib.mkdir(path.toStringz, mode);
        if (ret == 0)
        {
            return IOResult(true);
        }
        return IOResult(CError(cstdlib.errno));
    }
}

private unittest
{
    auto res = IOUtil.copyFile("LICENSE", "LICENSE.test");
    scope (exit)
    {
        cstdlib.unlink("LICENSE.test".toStringz);
    }
    res.match!((err) => assert(0, err.toString), (ok) {});
}
