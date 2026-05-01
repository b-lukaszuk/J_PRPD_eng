# The Doors {#sec:the_doors}

In this chapter I used the following libraries.

```jl
s2 = """
import DataFrames as Dfs # external library
import Random as Rnd # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/the_doors)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:the_doors_problem}

There is this famous game-show host problem, also known as [the Monty Hall
problem](https://en.wikipedia.org/wiki/Monty_Hall_problem) that goes something
like this.

Imagine there is a game-show in which a person may win a new car. The car is
hidden behind one of three doors. The host chooses a player (called a trader)
from the people in the studio and asks them to pick one door. The choice is
Door 1. The host knows what's behind all the doors. He decided to open Door 3,
behind which there's a goat. Now the trader got a choice: stay with their
initial choice, or switch to still unopened Door 2.

Imagine you are the trader. What would you do? Is it in your interest to make a
switch? Use Julia to figure it out.

## Solution {#sec:the_doors_solution}

One way to answer the question is to use the so called Bayes's Theorem, as
explained by Allen B. Downey
[here](https://allendowney.github.io/ThinkBayes2/chap02.html#the-monty-hall-problem).

> **_Note:_** Below, you will find a shortened explanation. To understand the
> topic more satisfactorily you will likely need to read the first two chapters
> of [Think Bayes](https://allendowney.github.io/ThinkBayes2/index.html) by
> Allen B. Downey.

First the theorem:

$$P(A|B) = \frac{P(A) * P(B|A)}{P(B)}$$

which can be also written as:

$$P(H|D) = \frac{P(H) * P(D|H)}{P(D)}$$ {#eq:bayesTheorem}

where:

- P(H|D) - probability of a hypothesis given the obtained data (aka **posterior**),
- P(H) - probability of a given hypothesis upfront (aka **prior**),
- P(D|H) - probability of obtaining such data given the discussed hypothesis is true (aka **likelihood**),
- P(D) - the total probability of the data under all the considered hypotheses.

Regarding the **priors** or P(H), initially it is equally likely for the car to
be behind any of the three doors. Therefore, the probability that the car is
behind Door X is: 1 out of 3, so 1/3. This can be represented as:

```jl
s = """
import DataFrames as Dfs

df = Dfs.DataFrame(Dict("Door" => 1:3))
df.prior = repeat([1//3], 3) # 1//3 is Rational (a fraction)
df
Options(df, caption="The doors. Priors.", label="theDoorsPriors")
"""
replace(sco(s), Regex("Options.*") => "", "1//1" => "1", "2//1" => "2", "3//1" => 3)
```

Let's move to **likelihood** or P(D|H). If the car was behind Door 1, then the
host may open either Door 2 or Door 3. Hence, the probability of him opening
Door 3 (as he did in the problem description) is 1 out of 2, so 1/2 or 0.5. If
the car was behind Door 2, then the host had no other option but to open Door 3
(since Door 1 is the trader's choice and he doesn't want to reveal the car
behind Door 2). Therefore, in this case the probability is equal to 1 (certain
event). If the car were behind Door 3, then there is no way the host would have
opened it (since it would have revealed the car and spoiled the game). So, in
this case the probability is 0.

Let's add this information to the table.

```jl
s = """
df.likelihood = [1//2, 1, 0]
df
Options(df, caption="The doors. Likelihoods.", label="theDoorsLikelihood")
"""
replace(sco(s), Regex("Options.*") => "", "1//1" => "1", "2//1" => "2", "3//1" => 3)
```

Now we perform a so called Bayesian update, e.g. per the formula in
@eq:bayesTheorem: first we multiply $P(H)$ (prior) by $P(D|H)$ (likelihood) then
we divide it by $P(D)$ (sum of all probabilities) like so:

```jl
s = """
function bayesUpdate!(df::Dfs.DataFrame)::Nothing
    unnorm = df.prior .* df.likelihood
    df.posterior = unnorm ./ sum(unnorm)
    return nothing
end

bayesUpdate!(df)
df # to see Rationals as floats: convert.(Flt, df.posterior)
Options(df, caption="The doors. Posteriors.", label="theDoorsPosterior")
"""
replace(sco(s), Regex("Options.*") => "", "1//1" => "1", "2//1" => "2", "3//1" => 3)
```

Clearly, switching to Door 2 gives the trader a better chance of winning the car
($P = \frac{2}{3} \approx 0.66$) than remaining with the original choice ($P =
\frac{1}{3} \approx 0.33$).

> **_Note:_** To see the posterior as floats you may use, e.g.
> `convert.(Flt, df.posterior)`.

If that doesn't convince you then let's do a computer simulation.

```jl
s = """
import Random as Rnd

mutable struct Door
    isCar::Bool
    isChosen::Bool
    isOpen::Bool
end

function get3RandDoors()::Vec{Door}
    cars::Vec{Bool} = Rnd.shuffle([true, false, false])
    chosen::Vec{Bool} = Rnd.shuffle([true, false, false])
    return [Door(car, chosen, false)
            for (car, chosen) in zip(cars, chosen)]
end

# open first non-chosen, non-car door
function openEligibleDoor!(doors::Vec{Door})::Nothing
	@assert length(doors) == 3 "need 3 doors"
	indEligible::Int = findfirst(d -> !d.isCar && !d.isChosen, doors)
	doors[indEligible].isOpen = true
    return nothing
end

# swap to first non-chosen, non-open door
function swapChoice!(doors::Vec{Door})::Nothing
    @assert length(doors) == 3 "need 3 doors"
    indCurChosen::Int = findfirst(d -> d.isChosen, doors)
    ind2Choose::Int = findfirst(d -> !d.isChosen && !d.isOpen, doors)
    doors[indCurChosen].isChosen = false
    doors[ind2Choose].isChosen = true
    return nothing
end
"""
sc(s)
```

We start by defining a `Door` structure that has all the necessary fields so
that we can simulate our game-show. Notice the `mutable` keyword, it will allow
us to change a property of a `Door` in-place. Anyway, we follow the structure
definition with a random generator of three doors (`get3RandDoors`), a door
opener (`openEligibleDoor`) and `swapChoice`. All the above act per the game
description.  Of note,
[findfirst](https://docs.julialang.org/en/v1/base/arrays/#Base.findfirst-Tuple%7BFunction,%20Any%7D)
accepts a predicate and a vector. The predicate is a function that is executed
on consecutive elements of the vector (`doors`) and returns `true` or `false`
for each of them. In the end `findfirst` returns the first index from the vector
(`doors`) for which the predicate was `true` or `nothing` if no such thing
happened. Normally, we should handle both the possible cases (`Int` if `true`
and `nothing` if all the tests came negative). However, if we're pretty sure to
get the `Int` and actually we want to get the error if we're mistaken, then we
may leave it as in the code snippet above.

Now, we only need a way to determine did the player win.

```jl
s = """
function didTraderWin(doors::Vec{Door})::Bool
    indWinner::Union{Nothing, Int} = findfirst(
        d -> d.isChosen && d.isCar, doors)
    # or: return !isnoting(indwinner)
    return isnothing(indWinner) ? false : true
end

function getResultOfDoorsGame(shouldSwap::Bool=false)::Bool
    doors::Vec{Door} = get3RandDoors()
    openEligibleDoor!(doors)
    if shouldSwap
        swapChoice!(doors)
    end
    return didTraderWin(doors)
end
"""
sc(s)
```

Of note, in the above snippet we used `findfirst` once more. However, this time
we may not find the index of a winner (`indWinner`). We mark that possibility
with an `Union` type (`indWinner` is an `Int` if behind the doors chosen by the
trader is a car or `nothing` otherwise). Lastly, we handle such a situation with
[isnothing](https://docs.julialang.org/en/v1/base/base/#Base.isnothing) and a
[ternary expression](https://docs.julialang.org/en/v1/base/base/#?:).

Now we are ready to estimate the probability:

```jl
s = """
# treats: true as 1, false as 0
function getAvg(successes::Vec{Bool})::Flt
    return sum(successes) / length(successes)
end

function getProbOfWinningDoorsGame(shouldSwap::Bool=false,
                                   nSimul::Int=10_000)::Flt
    @assert 1e3 <= nSimul <= 1e5 "nSimul must be in range [1e3 - 1e5]"
    return [getResultOfDoorsGame(shouldSwap) for _ in 1:nSimul] |> getAvg
end

Rnd.seed!(1492)
getProbOfWinningDoorsGame(false), getProbOfWinningDoorsGame(true)
"""
sco(s)
```

which ends up to be equivalent to our theoretical calculations.

I suppose you could argue the doing 10,000 computer simulations to estimate the
probability is overkill, after all the total number of possibilities cannot be
that big for this simple case. Well, I guess you're right. So, let's try again,
this time we will list all the possible scenarios and see in how many of them we
succeed.

```jl
s = """
# list all the possibilities of car location and choice location
function getAll3DoorSets()::Vec{Vec{Door}}
    allDoorSets::Vec{Vec{Door}} = []
    subset::Vec{Door} = Door[]
    for indCar in 1:3, indChosen in 1:3
        subset = [Door(false, false, false) for _ in 1:3]
        subset[indCar].isCar = true
        subset[indChosen].isChosen = true
        push!(allDoorSets, subset)
    end
    return allDoorSets
end
"""
sc(s)
```

Now we change the `return` statements in our `openEligibleDoor!` and
`swapChoice`.

```jl
s = """
# open first non-chosen, non-car door
function openEligibleDoor!(doors::Vec{Door})::Vec{Door}
    @assert length(doors) == 3 "need 3 doors"
    indEligible::Int = findfirst(d -> !d.isCar && !d.isChosen, doors)
    doors[indEligible].isOpen = true
    return doors # instead of: return nothing
end

# swap to first non-chosen, non-open door
function swapChoice!(doors::Vec{Door})::Vec{Door}
    @assert length(doors) == 3 "need 3 doors"
    indCurChosen::Int = findfirst(d -> d.isChosen, doors)
    ind2Choose::Int = findfirst(d -> !d.isChosen && !d.isOpen, doors)
    doors[indCurChosen].isChosen = false
    doors[ind2Choose].isChosen = true
    return doors # instead of: return nothing
end
"""
sc(s)
```

Thanks to this small change we can answer our question with this few-liner.

```jl
s = """
map(didTraderWin ∘ openEligibleDoor!, getAll3DoorSets()) |> getAvg,
map(didTraderWin ∘ swapChoice! ∘ openEligibleDoor!,
	getAll3DoorSets()) |> getAvg
"""
sco(s)
```

> Note, `∘` is a [function composition
> operator](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping)
> that you can obtain by typing `\circ` and pressing Tab. The `map(fn2 ∘ fn1,
> xs)` means take every `x` of `xs` and send it to `fn1` as an argument. Then
> send the result of `fn1(x)` as an argument to `fn2`. Finally, present the
> result of `fn2(fn1(x))` (executed on all `xs`) as a collection.

And that's it. Three methods, three similar results. Time to make that door
swap.

> Note, the code presented above may not work for other number of doors
> scenarios.
