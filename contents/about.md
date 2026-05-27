# About {#sec:about}

Hi, I'm Bart and this is my second open access book entitled:

"Julia. Projects from a Recreational Programmer's Drawer"

> **_Note:_** The book was written by an amateur programmer (with all its
> potential negative consequences). If you find this a problem, stop reading
> now.

The book contains a set of challenges of varying level of complexity (most
likely in the range of easy to moderate). The exercises are for the problems
that, for whatever reason, I found interesting and/or suitable. The tasks are
possibly self-contained and accompanied by exemplary solutions in
[Julia](https://julialang.org/) (with explanations). Still, I recommend you try
to solve the tasks yourself. Alternatively you may read the solutions and try to
recreate them as much as you can on your own. The key thing is, if you want to
learn, write the code.

For practical reasons, I will assume this book is read by curious readers of
non-mathematical (i.e. resembling mine) background. Moreover, I expect that the
readers have already mastered the language basics and now are on a lookout for a
way to hone their newly acquired skills. To that end, I'll imagine you have read
[my previous open access book](https://b-lukaszuk.github.io/RJ_BS_eng/). I'll do
this not because it is the best book in the world (which it is), but because of
the [DRY principle](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) (I'm
going to apply similar conventions without delving too much into the previously
mentioned topics).

For instance, just like in the previous book, here I will use the
[assert](https://docs.julialang.org/en/v1/base/base/#Base.@assert) macro to
test a function's assumptions and print error messages. The construct is not
recommended in a serious program (see the warning in the docs), but for the
purpose of this book it should do the trick.

Additionally, henceforth I will define a few type aliases, like:

```jl
s = """
const Flt = Float64
const Str = String
const Vec = Vector
"""
sc(s)
```

This will allow for a shorter code when type declarations are used,
e.g. `Vec{Flt}` instead of `Vector{Float64}`. Notice, that the type synonyms are
declared with `const` keyword, since they will not change for as long as a
program runs. The naming convention for the custom types is similar to the name
of the built in data types in Julia (first letter is uppercased, the rest of the
characters are lowercased).

I wrote this book using Julia:

```jl
s = """
VERSION
"""
sco(s)
```

so an [LTS](https://en.wikipedia.org/wiki/Long-term_support) edition with the
following internal (available to you after installment):

- Base
- Dates
- Random
- Statistics
- Test

and external (downloaded from the internet separately) libraries:

- BenchmarkTools
- CairoMakie
- DataFrames
- Makie
- Symbolics

Still, you should be able to solve the tasks with the functionality that comes
with your installation (not necessarily the ones named above).

If, for any reason, this book is not to your taste then feel free to visit,
e.g. Adam Wysokinski's the [Big Book of
Julia](https://adamwysokinski.codeberg.page/bbj/) and choose a learning resource
of your liking. Alternatively you may visit [Rosetta Code
web-page](https://rosettacode.org/wiki/Category:Solutions_by_Programming_Task)
that contains over 1'000 programming exercises with solutions in different
programming languages. Chances are that many of the exercises presented here are
to be found there (not that I copied them, it's just that they've been around
for quite some time and I don't even know whom should I give credit for them).

Finally, just like in the previous book, I'll try to write in a possibly simple
(clarity over cleverness and performance) and correct manner. Still, I'm only
human, so watch out for possible errors and bugs. Anyway, I hope the book will
satisfy your appetite, it is available freely under [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0
International](http://creativecommons.org/licenses/by-nc-sa/4.0/) license.

Let the games begin.
