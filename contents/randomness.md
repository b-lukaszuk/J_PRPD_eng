# Randomness {#sec:randomness}

In this chapter I used the following libraries.

```jl
s2 = """
import Dates as Dt # internal library
import Statistics as St # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/randomness)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:randomness_problem}

Random numbers are the numbers that occur, well, at random. Anyway, they are
quite useful for programming. Chances are you will use them to solve some
problems like those in @sec:birthday_problem or @sec:logo_problem.

But how do computers generate them. Surprise, they don't. But then how could a
Julia's `Random.jl` (part of the standard library) generate one. Hmm, it's
complicated, but the basic idea could be explained with an example.

In a moment I will use a function that generates a random number in the range of
1 to 10 (inclusive-inclusive). Take a moment and try to guess it.

Ready, here we go.

```
getRand()
```

The number was seven. Did you guess it? If so, congrats! The popular psychology
claims that for the said range people most often choose 7 and 3 so I wonder just
how many of you, the readers, succeeded. Anyway, let me try again, I will use
[comprehensions](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_repetition.html#sec:julia_language_comprehensions)
to generate 10 random numbers and you will try to guess the next one, ready.

```
[getRand() for _ in 1:10]
```

```
[8, 9, 10, 1, 2, 3, 4, 5, 6, 7]
```

OK, what's the next number?

You got it, it's 8. Now let's examine this sub-optimal number generator.

```
seed = 6

function getRand()::Int
    newSeed::Int = (seed % 10) + 1
    global seed = newSeed
    return newSeed
end
```

First, we declare a variable called `seed` with an initial, undisclosed and hard
to predict value. From this `seed` our random numbers will sprout. Next, inside
`getRand` we update the `seed ` using some mathematical formula and return it as
our result. Moreover, we update the old `seed ` with that new value
(`global seed = newSeed`, we use
[global](https://docs.julialang.org/en/v1/base/base/#global) since here `seed`
is in the global
[scope](https://docs.julialang.org/en/v1/manual/variables-and-scoping/#scope-of-variables)).
Thanks to the update the next time we use `getRand` it will return us some new
value. Still, the function is purely deterministic as once you know the value of
`seed` you can accurately predict the random variable you will get.

Surprisingly this is more or less what the [random number
generators](https://en.wikipedia.org/wiki/Random_number_generation) do. The idea
we got there was not bad, we just need to improve on its execution. We need a
less obvious starting value, a more chaotic update method, and a much longer
looping period so that no one sees that the sequence repeats itself
periodically.

And here we are. In this chapter we are going to develop a simplified library
for random numbers generation.

First, pick a [random number
generator](https://en.wikipedia.org/wiki/List_of_random_number_generators#Pseudorandom_number_generators_(PRNGs))
that is relatively easy to implement
([LCG](https://en.wikipedia.org/wiki/Linear_congruential_generator) seems to be
good enough, but it's up to you). The `seed` is often initialized with [epoch
time](https://en.wikipedia.org/wiki/Epoch_(computing)), e.g. the number of
seconds that passed since 1 January 1970, which is kind of unpredictable. You
should be able to get it out of the
[Dates](https://docs.julialang.org/en/v1/stdlib/Dates/) module. Use the LCG to
write `getRand` that returns a random `Float64` in the range `[0-1)`
(inclusive - exclusive). This is our bread and butter of random number
generation. It works similar to JavaScript's `Math.random()` or Julia's `rand()`
(`Base.rand` imports it from `Random.jl`). Next, define another `getRand`
method, the one that returns a random integer from a given range. To cool down
read about [Box-Mueller
transform](https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform) and use
it to define two `getRandn` methods, one that returns a value from a [standard
normal
distribution](https://en.wikipedia.org/wiki/Normal_distribution#Standard_normal_distribution)
with the mean = 0 and the standard deviation = 1 (like `Base.randn` do). The
other should return a normal distribution with a specified mean and standard
deviation.

If the above feels overwhelming, then proceed one step at a time and do as much
as you can. Remember you need to understand this stuff enough to implement it in
the code, leave the theorems and proofs to mathematicians and trust that they
did their jobs right.

## Solution {#sec:randomness_solution}

We start by defining a few global variables required by LCG as well as a a way
to set our `seed` to a desired value.

```jl
s = """
import Dates as Dt

a = 1664525
c = 1013904223
m = 2^32
seed = round(Int, Dt.now() |> Dt.datetime2unix)

function setSeed!(newSeed)::Nothing
    global seed = newSeed
    return nothing
end
"""
sc(s)
```

The values were chosen based on [this table from
Wikipedia](https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use).

Time to translate the LCG algorithm to Julia's code.

```jl
s = """
function getRandFromLCG()::Int
    newSeed::Int = (a * seed + c) % m
    setSeed!(newSeed)
    return newSeed
end
"""
sc(s)
```

> **_Note:_** In general a function should not rely on nor change global
> variables. Instead it should only depend on the parameters that were send to
> it as its arguments. Relying on global variables although convenient and
> tempting could lead to bugs that are hard to pinpoint and eliminate. That's
> why in the rest of this book I will try to avoid this style with the exception
> of global constant variables seen, e.g. in @sec:calendar_solution.

Let's see how it works.

```jl
s = """
# your numbers will likely differ from mine
[getRandFromLCG() for _ in 1:6]
"""
sco(s)
```

A small victory. In result we got some integers that are very hard to predict
for a human brain alone.

Still, the numbers are unwieldy and look quite odd. How can we transform them
into a function that returns `Float64` from the range `[0-1)`? The key is the
modulo operator (`%` equivalent to `rem` function) in `getRandFromLCG`. All it
is is just a reminder after a division. It has an interesting property, the
remainder of `i` divided by `m` is always in the range 0 to `m-1`, see the
example below.

```jl
s = """
[i % 3 for i in 1:7]
"""
sco(s)
```

If so then all we have to do is to divide our `seed` (that takes values from 0
to `m`-1) by `m` to get the desired `Float64` value.

```jl
s = """
function getRand()::Flt
    return getRandFromLCG() / m
end

# your numbers will likely differ from mine
[getRand() for _ in 1:3]
"""
sco(s)
```

Much better, we reached the first checkpoint. OK, now how to convert it to a
random integer generator. Let's try one step at a time. The `getRand()` returns
a `Float64` in the range `[0-1)`. So, if we were to multiply 1 (the upper limit)
by let's say 5 we would get 5, and 0 (the lower limit) times 5 would get us
zero. Hence, the following code (`floor` returns the nearest integer smaller
than or equal to a `Float64`).

```jl
s = """
function getRand(upToExcl::Int)::Int
    @assert 0 < upToExcl "upToExcl must be greater than 0"
    return floor(getRand() * upToExcl)
end
"""
sc(s)
```

Time for a test. If we did our job right we should get a sequence of random
values each equally likely to occur (`getCounts` was developed and explained
[here](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_prob_theor_practice.html)).

```jl
s = """
function getCounts(v::Vec{T})::Dict{T,Int} where T
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

setSeed!(1111) # for reproducibility
[getRand(3) for _ in 1:100_000] |> getCounts
"""
sco(s)
```

Yep, roughly equal counts. One more swing with a different range.

```jl
s = """
setSeed!(1111) # for reproducibility
[getRand(5) for _ in 1:100_000] |> getCounts
"""
sco(s)
```

Ladies and gentlemen, we got it. Now, let's tweak it a bit so that we can get an
integer in the desired range.

```jl
s = """
function getRand(minIncl::Int, maxIncl::Int)::Int
    @assert 0 < minIncl < maxIncl "must get: 0 < minIncl < maxIncl"
    return minIncl + getRand(maxIncl-minIncl+1)
end

function getRand(n::Int, minIncl::Int, maxIncl::Int)::Vec{Int}
    @assert 0 < n "n must be greater than 0"
    return [getRand(minIncl, maxIncl) for _ in 1:n]
end
"""
sc(s)
```

For that we just generated an `Int` from 0 up to one more than the span of our
range (`maxIncl-minIncl+1`) and added `minIncl` so that the range starts at that
value and not at zero. Let's check it out.

```jl
s = """
setSeed!(2222)
getRand(100_000, 1, 4) |> getCounts
"""
sco(s)
```

Looks good, roughly equal counts was what we were looking for. One more time,
just to be sure.

```jl
s = """
setSeed!(2222)
getRand(100_000, 3, 7) |> getCounts
"""
sco(s)
```

Another checkpoint reached.

As for the Box-Mueller transform there is a small problem. The Wikipedia's page
already contains [the algorithm implementation in
Julia](https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform#Julia). So for
a change we will take the [JavaScript
version](https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform#JavaScript)
and translate it to Julia.

```jl
s = """
function getRandn()::Tuple{Flt, Flt}
    theta::Flt = 2 * pi * getRand()
    R::Flt = sqrt(-2 * log(getRand()))
    x::Flt = R * cos(theta)
    y::Flt = R * sin(theta)
    return (x, y)
end

"""
sc(s)
```

And voila, the only difference is that instead of a vector we return a tuple
with each element being a value from the normal distribution with the mean = 0
and the standard deviation = 1. However, we would prefer a function that returns
any number of normally distributed values (and not only two in
`Tuple{Flt, Flt}`), hence the following code.

```jl
s = """
function flatten(randnNums::Vec{Tuple{Flt, Flt}})::Vec{Flt}
    len::Int = length(randnNums) * 2
    result::Vec{Flt} = Vec{Flt}(undef, len)
    i::Int = 1
    for (a, b) in randnNums
        result[i] = a
        result[i+1] = b
        i += 2
    end
    return result
end

function getRandn(n::Int)::Vec{Flt}
    @assert n > 0 "n must be greater than 0"
    roughlyHalf::Int = cld(n, 2)
    return flatten([getRandn() for _ in 1:roughlyHalf])[1:n]
end
"""
sc(s)
```

`getRandn(n::Int)` generates a vector of tuples using comprehensions. The length
of the vector is determined using `cld`, which divides `n` by 2, and returns the
smallest integer equal to or greater than the result of that division. The
vector of tuples (in this case `Vec{Tuple{Flt, Flt}}`) is `flatten`ed before
being returned from `getRandn(n::Int)`. That's why we get a regular vector of
floats (`Vec{Flt}`). Notice, that if `n` is an odd number then we return all but
the last element (`[1:n]`) of the vector (since `flatten` returns a vector of
even length). Anyway, let's see how we did.

```jl
s = """
import Statistics as St

# test: mean ≈ 0.0, std ≈ 1.0
setSeed!(401)
x = getRandn(100)

St.mean(x), St.std(x)
"""
sco(s)
```

I would say we did a pretty good job.

Time for the last step, let's transform `getRandn` to a function that provides a
normal distribution with a specified mean and standard deviation. That's fairly
simple. Since the 'original' deviation is 1, then if we multiply the numbers by
let's say 16, then we will get a distribution with the mean 0 and standard
deviation equal to 16. So how do we make a mean equal, let's say 100? It's easy
as well, we just add 100 to every number from a distribution.

```jl
s = """
function getRandn(n::Int, mean::Flt, std::Flt)::Vec{Flt}
    return mean .+ std .* getRandn(n)
end

# test: mean ≈ 100.0, std ≈ 16.0
setSeed!(401)
x = getRandn(100, 100.0, 16.0)

St.mean(x), St.std(x)
"""
sco(s)
```

That seems to be it, we reached the end of this task. Together we developed a
simplified library for random numbers generation and it wasn't all that bad, was
it? Still, for practical reasons I would recommend to use the baptized in fire
[Random.jl](https://docs.julialang.org/en/v1/stdlib/Random/).
