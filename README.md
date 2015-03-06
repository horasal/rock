[![Build Status](https://travis-ci.org/zhaihj/rock.svg?branch=master)](https://travis-ci.org/zhaihj/rock)

## A fork of [rock](https://github.com/fasterthanlime/rock)

### todo

* ~~add cmake driver~~ -> Partially Finished
* ~~fix variables with nested closure~~ -> Finished
* ~~ooc-doc only starts with /\* and //~~ -> Finished
* ~~inconsistent slice~~ -> Fixed
* ~~match() case 1, 2, 3 =>~~ -> Finished
* match() case 1..3 =>
* ~~fix reference to variables in nested closure -> Working~~ -> Fixed
* ~~update grammar to avoid segment fault -> foo()(), a ::= 3 & call a as function~~ -> Fixed
* ~~version block -> parser can not catch correct structure for version{ if else }else{}~~ -> Fixed, but need review
* inline function -> implementing
* better array by template
* cmake driver for windows
* ~~common root for numbers -> implementing in branch:commentroot~~ -> Mostly fixed
* layer-wise function search -> Working
* add function type scope
with restriction of generic type, we can do :
extend ArrayList<Int>{
    //something
}
and make this only work for `Int`
* and more... check [commits list](https://github.com/zhaihj/rock/commits/master) to find more fixed issues in this fork


# rock

  * [ooc](http://ooc-lang.org/)
  * [rock](https://github.com/fasterthanlime/rock)

rock is an ooc compiler written in ooc - in other words, it's
where things begin to become really exciting.

it has been bootstrapping since April 22, 2010 under Gentoo, Ubuntu,
Arch Linux, Win32, OSX...

## Prerequisites

You need the following packages when building rock:

* GNU Make (`make` or `gmake`, depending on your operating system)
* boehm-gc
* tar (for extracting the C sources)
* bzip2 (used by tar)

## Get started

Run `make rescue` and you're good.

## Wait, what?

`make rescue` downloads a set of C sources, compiles them, uses them to compile your copy of rock,
and then uses that copy to recompile itself

Then you'll have a 'rock' executable in bin/rock. Add it to your PATH, symlink it, copy it, just
make sure it can find the SDK!

## Install

See the `INSTALL` file

To switch to the most recent git, read
[ReleaseToGit](https://github.com/fasterthanlime/rock/blob/master/docs/workflow/ReleaseToGit.md)

## License

rock is distributed under the MIT license, see `LICENSE` for details.

Boehm GC sources are vendored, it is distributed under an X11/MIT-like license,
see `libs/sources/LICENSE` for details.
