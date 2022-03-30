# Metaprogramming

What do we mean by "metaprogramming"? Well, it was the best collective term we could come up with for the set of things that are more about *process* than about writing code or working efficiently.

We'll look at systems for building and testing your code, and managing dependencies.

## Build systems

If you write a paper in LaTeX, what are the commands you need to run to produce your paper? What about the ones used to run your benchmarks, plot them, and then insert that plot into your paper? OR to compile the code provided in the class you're taking and then running the tests?

For most projects, whether they containi code or not, there is a "build process". Some sequence of operations you need to go from your inputs to your outputs. Often, this many have many steps/branches. Run this to generate this plot, that to generate those results, etc. Thankfully, there's tools for this!

These are usually called "build systems", and there are *many* of them. Which one you use depends on your task, your language, and the size of the project. At their core, they are all very similar though. You define a number of *dependencies*, a number of *targets*, and *rules* for going from one to the other. You tell the build system that you want a particular target, and its job is to find all the transitive dependencies of that target, and then apply the rules to produce intermediate targets all the way until the final target has been produced. Ideally, the build system does this without unnecessarily executing rules for targets whose dependencies haven't  change and where the result is available from a previous build.

`make` is one of the most common build systems out there, and you'll usually find it installed on pretty much any UNIX-based computer. It has its warts, but it works well for simple-to-moderate projects. When you run `make`, it consults a file called `Makefile` in the current directory. All the targets, their dependencies, and the rules are defined in that file. Let's take a look at one:

```sh
paper.pdf: paper.tex plot-data.png
  pdflatex paper.tex

plot-%.png: %.dat plot.py
  ./plot.py -i $*.dat -o $@
```

Each directive in this file is a rule for how to produce the left-hand side using the right-hand side. Or, phrased differently, the things named on the right are dependencies, and the left are targets. The indented block is a sequence of programs to produce the target from those dependencies. In `make`, the first directive also defines the default goal. If you run `make` with no arguments, this is the target it will build. Alternatively, you can run something like `make plot-data.png` and it will build that target instead.

The `%` in a rule is a "pattern", and will match the same string on the left and on the right.

`make` will only re-run the steps where dependencies have changed!

## Dependency management

At a more macro level, your software projects are likely to have dependencies that are themselves projects. You might depend on installed programs (eg. `python`), system packages (eg. `openssl`) or libraries within your programming language (eg `numpy`). These days, most dependencies are available through a *repository* that bosts a large number of such dependencies in a single place, and provides a convenient mechanism for installing them. For example, RubyGems for Ruby, PyPI for Python, `apt` for Ubuntu, etc.

Since the exact mechanisms for interacting with these repositories vary a lot, we won't go too into detail for any specific one. We *will* cover some common terminology. The first is *versioning*. Most projects that other projects depend on issue a *version number* with every release. Usually something like `8.1.3` or `64.1.20192004`. They are often numerical. Version numbers serve many purposes, one of which is to ensure that software keeps working. Imagine if a library updated in a way that changed the interface. Any software that depends on that library could break, hence why we specify versions - any dependents can keep using the older version.

A common standard is *semantic versioning*. With semantic versioning, every version number is of the form: `major.minor.patch`. The rules are:

* If a new release does not change the API, increase the patch version
* If you *add* to your API in a backwards-compatible way, increase the minor version
* If you change the API in a non-backwards-compatible way, increase the major version

This provides some major advantages. If a project depends on a library, it *should* be safe to use the latest release with the same major version as the one it was originally built against, as long as its minor version is at least what it was back then. In other words, if I depend on your library at version `1.3.7`, then it *should* be fine to build with `1.3.8`, `1.6.1`, or even `1.3.0`. Version `2.2.4` would probably not be OK, and `1.2.3` may not be either.

When working with dependency management systems, you may also come across the notion of *lock files*. A *lock file* is a file that lists the exact version you are *currently* depending on for each dependency. Usually, you need to explicitly run an update program to upgrade to newer versions of your dependencies. There are many reasons for this, such as avoiding unnecessary recompiles, haviing reproducible builds, or not automatically updating to the latest version (which could be broken). An extreme version of this kind of dependency locking is *vendoring*, which is where you copy all the code of your dependencies into your own project. This gives total control over any changes, and lets you introduce your own changes to it, but also means that you have to explicitly pull in any updatess from the upstream maintainers over time.

## Continuous integration systems

As you work on larger and larger projects, you'll find that there are often additional tasks you have to complete whenever a change is made. You may have to upload a new version of the documentation, upload a compiled version somewhere, release the code to PyPI, run your test sutie, etc. Maybe every time someone sends a PR a GitHub, the code should be style checked and benchmarked? When these needs arise, look at CI.

CI is an umbrella term for "stuff that runs whenever your code changes". Many companies provide various types of CI, often for free for open-source projects - Travis CI, Azure Pipelines, GitHub Actions, etc. They all work roughly the same - you add a file to your repository that describes what should happen when various things happen to that repository. By far the most common is a rule like "when someone pushes code, run the test suite". When the even triggers, the CI provider spins up one or more VMs, runs the commands in your "recipe", and usually notes down the results somewhere. You might set it up so you are notified in the test suite fails, or so a little badge appears on your repository when tests pass.

### A brief aside on testing

Most large projects come with a "test suite". You may already be familiar with general concepts of testing, but let's quickly mention some approaches and terminology:

* **Test suite** - a collective term for all the tests
* **Unit test** - a "micro-test" that tests a specific feature in isolation
* **Integration test** - a "macro-test" that runs a larger part of the system to check that different features/components work together
* **Regression test** - a test that implements a particular pattern that *previously* caused a bug to ensure the bug doesn't resurface
* **Mocking** - to replace a function, module, or type with a fake implementation to avoid testing unrelated functionality.
