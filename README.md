C Mangler: a 15 line solution to a 40 year old C problem
--------------------------------------------------------

Problem: C libraries pollute global namespace with their procedure and data names.

Example: a developer A writes his C library with a procedure called `add` that adds two numbers,
a developer B wants to use developer A's library, he downloads the library and its header files,
includes them in his project and hits a compile button which throws an error: `add` is already
declared somewhere in developer B's code. Developer B has no other choice other than either
go and manually replace `add` procedure in developer A's code (which won't be an easy task
given a standard regex string replace may rename something unrelated) or rename his / her
procedures or data structures just to not conflict with developer A's link names.

Solution: just decouple procedure and data code names from their link names.

How to: on Linux (only, for now), run `build_mylibrary.sh` script to build a very simple C library with
2 global procedures: `myrsqrt` and `mysqrt`. Then run `nm --no-sort --defined-only --extern-only mylibrary.a`
command to see their link names defined in our compiled library:

```bash
0000000000000000 T myrsqrt
0000000000000104 T mysqrt
```

This is the standard process of compiling all C libraries out there. Now the interesting part: how would we
decouple their names in code from their link names in an automatic, almost non-intrusive, non-build-breaking
way, so we could run some commands without even touching someone else's codebase and get a library which
procedures and data names won't collide with ours?

Here's what I found: we can couple global names with unique hash strings using... a plain define macro,
like so: https://github.com/procedural/c_a_new_way_of_developing_portable_libraries/blob/97419d1/mylibrary.h#L3-L4

Now we have *what appears to be* the same looking procedure and data names in human readable code, except their
actual link names are now 64 character long hashes with `_` prefixes for hashes which start with numbers.

Run `./c_mangler.sh mylibrary.a` to generate a `/tmp/c_mangler.h` header file that will contain defines for all global
procedures and data structs of the library and... Here's another interesting thing it will do to all .c and .h files in
a folder where `c_mangler.sh` script is placed: to be compatible with all C build systems out there, it will inject a
`#include "/tmp/c_mangler.h"` line at the very top of each source file so that *we could uniformly lie about the names*
to a library.

Now compile the library by running `build_mylibrary.sh` again, but this time with all injected `#include "/tmp/c_mangler.h"`
lines in its source files. Run `nm --no-sort --defined-only --extern-only mylibrary.a` again and see:

```bash
0000000000000104 T _afb209dd57a3509176cb7c69f3aea504c13178e2f8ece6e4ef24a8e6c242db1a
0000000000000000 T _ca0793315b136019ed225ef09ce984448971bce5cf5df129f1240fb523428c9f
```

Tada! These hash names are here for the linker, for you, get the `/tmp/c_mangler.h` file that maps human readable procedure and
data names to these hashes. **Now you can rename global procedures and data however you want** in this and library's original
header files, include this header before including library's headers and get the working result. It will work no matter which
names you will use in code, they're decoupled from their link names now.

If this trickery won't make C libraries easier to interop for everyone, it will definitely help me: I can build your
code-name-link-name-unaware libraries and postprocess them with this script so they won't collide with my global
procedures and data structures.
