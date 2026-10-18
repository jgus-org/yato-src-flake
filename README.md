# yato-src-flake

A Nix flake that pins the source of [Yato](https://github.com/agruzdev/Yato), a header-only C++ template library (Alexey Gruzdev): STL-styled containers, ranges, iterators, type traits, an actor system and a type-safe configuration interface. Yato is not packaged in nixpkgs, so a build that needs it takes it from here.

## What you get

`packages.default` — the same output as `packages.yato-src` — is upstream's checkout at one pinned commit, fetched as a fixed-output source. Nothing is configured, built or installed, so the output is upstream's tree as-is: `include/`, `modules/`, `CMakeLists.txt`, `tests/`, `doc/`, `extras/` at the top level, and no `$out/lib`.

It is exposed for `x86_64-linux`, `aarch64-linux`, `x86_64-darwin` and `aarch64-darwin`. Headers carry nothing host-specific.

## Consuming it

Add the input, then put its include root on your compile line:

```nix
NIX_CFLAGS_COMPILE = "-I${yato-src.packages.${system}.default}/include";
```

Headers are included as `<yato/…>`, for example `#include <yato/variant.h>`.

A CMake build can instead take the tree as a subproject — `add_subdirectory()` on it and link the `Yato` interface target it defines, which upstream exports as `Yato::Yato`.

## Facts worth knowing before you do

- Module headers live outside `include/`. The actor system is under `modules/actors/` and the configuration module under `modules/config/`; upstream puts those on the include path only when it enables the corresponding module, so on the include-root route add those directories yourself.
- Upstream's own build defaults to C++20 (`YATO_CXX_STANDARD`, selectable down to C++17 or C++14). If you take the include route, that choice is yours to make.
- The pin names a commit on upstream's default branch. Upstream publishes no releases, its newest tag is `v1.1`, and the tree's own CMake project version is `1.2.0` — so the `0-unstable-<date>` version this flake's output carries is a date, not an upstream release number, and is not comparable with upstream tags.
- Yato is Apache-2.0; `LICENSE` ships in the output.
