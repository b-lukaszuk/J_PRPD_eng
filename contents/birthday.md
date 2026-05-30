# Birthday {#sec:birthday}

In this chapter I used the following libraries.

```jl
s2 = """
import Random as Rnd # internal library
import Statistics as St # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/birthday)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:birthday_problem}

The following is a classical [birthday
paradox](https://en.wikipedia.org/wiki/Birthday_problem) problem slightly
modified by me.

Imagine you're throwing a party for your birthday. You invited 30 people.
And now you begin to wonder:

1) what is the [probability](https://en.wikipedia.org/wiki/Probability) that any
two of your guests were born on the same day of a year?
2) what is the [probability](https://en.wikipedia.org/wiki/Probability) that any
of your guests were born on the same day of a year that you were born on?

Use Julia to answer the before-mentioned questions for the number of guests,
let's say, in the range [5-30].

## Solution {#sec:birthday_solution}

The following solution is based on a computer simulation and relies on a few
assumptions, namely:

1) there are always exactly 365 days in a year (no leap years)
2) a person is equally likely to have been born on any day of a year (no
seasonal, yearly and other patterns, etc.)
3) the birth date of one person does not influence the birth date of another
person (not in the case of twins, siblings, etc.)

None of the above is exactly true, still, those are some reasonable assumptions
that will allow us to knack the problem.

OK, let's begin.

```jl
s = """
import Random as Rnd

function getBdaysAtParty(nPeople::Int)::Vec{Int}
    @assert 5 <= nPeople <= 365 "nPeople must be in range [5-365]"
    return Rnd.rand(1:365, nPeople)
end

function getCounts(v::Vector{T})::Dict{T,Int} where T
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end
"""
sc(s)
```

We start by defining two simple functions. `getBdaysAtParty` returns a random
set of birthdays (`Vec{Int}`) drawn from all the possible days in a year
(`1:365`, with possible repetitions). On the other hand, `getCounts` is a
function that I copied-pasted from [my previous
book](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_prob_theor_practice.html).
It does what it promises, i.e. it returns a summary statistics (`counts`) that
tells us how many times a given day in the birthdays (result of
`getBdaysAtParty`) appears.

Time to find a way to determine does the event that we are looking for occurred
during the party.

```jl
s = """
function nSameBdays(counts::Dict{Int, Int}, n::Int=2)::Bool
    @assert 2 <= n <= 365 "n must be in range [2-365]"
    return isnothing(findfirst((>=)(n), counts)) ? false : true
end

function anyMyBday(counts::Dict{Int, Int}, myBday::Int=1)::Bool
    @assert 1 <= myBday <= 365 "myBDay must be in range [1-365]"
    return haskey(counts, myBday)
end
"""
sc(s)
```

First, we check for `nSameBdays` with the build in
[findfirst](https://docs.julialang.org/en/v1/base/arrays/#Base.findfirst-Tuple%7BFunction,%20Any%7D). That
function accepts a predicate and a collection (like a vector or a
dictionary). The predicate is a function that takes an element of a collection
(for a dictionary one of its values) as an input and returns a `Bool`.
`findfirst` brings back the first index (for vectors) or the first key (for
dictionaries) for which `predicate(vector's element)` or `predicate(dictionary's
value)` is `true`, respectively. Often a predicate is just an [anonymous
function](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions),
which in our case could be `key -> key >= n`. Instead, here I used a [partial
function application](https://bkamins.github.io/julialang/2024/02/23/fix.html).
The `(>=)(n)` is an equivalent of the `>= n` mentioned in the previous
sentence. It is just a function applied to one argument. The function still
lacks an argument on its left site, just before the `>`. This missing argument
will be any element of our collection that is currently being tested. Anyway,
one more point to notice, if `findfirst` finds no element for which the
predicate is `true` then it returns
[nothing](https://docs.julialang.org/en/v1/base/constants/#Core.nothing).
Therefore, to get our final answer we send the possible result through
[isnothing](https://docs.julialang.org/en/v1/base/base/#Base.isnothing) and [a
ternary
expression](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_decision_making.html#sec:ternary_expression)
. Technically, we could have shorten the last line to `return
!isnothing(firndfirst((>=)(n), counts))` (or even without the return), but I
thought that this might be too much condensation for a one line of code.

Our second function, `anyMyBday`, is much simpler. It just uses `haskey` to
check if our day of birth occurred in the birthdays of the guests at our party
(`counts`). Fun, fact, under our assumptions, it does not matter whether you
were born on the first or 365th day of the year. Go ahead, change the default
value to your actual day of birth and compare the result with the one provided
later in this chapter.

OK, time to estimate the probability of success, i.e. the ratio between the
number of times the event took place to the total trials (number of
simulations).

```jl
s = """
# isEventFn(Dict{Int, Int}) -> Bool
function getProbSuccess(nPeople::Int, isEventFn::Function,
                        nSimulations::Int=100_000)::Flt
    @assert 5 <= nPeople <= 366 "nPeople must be in range [5-365]"
    @assert 1e4 <= nSimulations <= 1e6 "nSimulations not in range [1e4-1e6]"
    successes::Vec{Bool} = Vec{Bool}(undef, nSimulations)
    for i in 1:nSimulations
        peopleBdays = getBdaysAtParty(nPeople)
        counts = getCounts(peopleBdays)
        eventOccured = isEventFn(counts)
        successes[i] = eventOccured
    end
    return sum(successes)/nSimulations
end
"""
sc(s)
```

First, we initialize the vector that will hold the results of our simulations
(`successes`). The `Vec{Bool}(undef, nSimulations)` creates a vector of size
specified in `nSimulations` that is currently occupied by some unspecified
(`undef` - undefined) values (basically garbage that is currently in a specific
place of our computer's memory). We will fill the `successes` with the values of
interest in the for loop. For each simulation, we throw a party and get the
guests' birthdays (`peopleBdays`). We obtain `count`s for them and test did the
event that we consider a success occurred that time (with `isEventFn`). We place
the occurrence into the proper spot (`[i]`) of our vector of
`successes`. Notice, that here `peopleBdays`, `counts`, and `eventOccured` are
local (helper) variables that are visible only in the for loop. Anyway, all
that's left to do is to calculate the probability. The `sum` function treats any
`true` as `1` and `false` as 0, hence it returns the number of successes, which
we divide by the number of simulations.

Let's see how it works.

```jl
s = """
Rnd.seed!(101)
peopleAtParty = 5:30
probsAnySameBdays = [getProbSuccess(n, nSameBdays) for n in peopleAtParty]
probsMyBday = [getProbSuccess(n, anyMyBday) for n in peopleAtParty]
"""
sc(s)
```

![Birthday paradox probabilities.](./images/birthday.png){#fig:birthday}

So, with 23 people at a party the probability that any 2 of them have a birthday
on the same day is roughly 50% or 0.5. The probability, that any person was born
the same day that I have been born is around 8% or 0.08 for 30 people at a
party. Actually, this last probability is fairly straightforward to
calculate. For the reasons explained
[here](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_probability_properties.html)
it is just $\frac{1}{365}*{n\ people\ at\ party}$ so our [mean absolute
error](https://en.wikipedia.org/wiki/Mean_absolute_error) is roughly equal to:

```jl
s = """
import Statistics as St

probsMyBdayTheor = (1/365) .* peopleAtParty
(probsMyBday .- probsMyBdayTheor) .|> abs |> St.mean
"""
sco(s)
```

which isn't all that bad.

As a mini-exercise you may tweak the code a little and estimate the probability
that any 3 people at a party were born on the same day.
