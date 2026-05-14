# Sort {#sec:sort}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/sort)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:sort_problem}

The Julia's built-in
[sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort) function is a
pretty useful beast. Let's try to replicate some of its functionality.

Read about different [sorting
algorithms](https://en.wikipedia.org/wiki/Sorting_algorithm#Comparison_of_algorithms)
and implement one or two of them. As a minimum requirement your sorting function/s
should correctly sort a vector of numbers (integers and floats), e.g.

```
yourSortingFn([47, 15, 23, 99, 4])
```

Should return:

```
[4, 15, 23, 47, 99]
```

If you want to make it more challenging, try to sort the numbers from 1 to 10 in
alphabetical order, e.g.

```
yourSortingFn([1, 11, 6], possibleOtherArgs)
```

should return:

```
[11, 1, 6]
```

Since "eleven" comes before "one" and before "six" ("e" < "o" < "s").

## Solution {#sec:sort_solution}

For our first attempt we'll go with something simple like the [bubble
sort](https://en.wikipedia.org/wiki/Bubble_sort) algorithm.

```jl
s = """
# sorts in ascending order
function bs(v::Vec{A})::Vec{A} where A<:Union{Flt, Int}
    result::Vec{A} = copy(v)
    swapped::Bool = true
    while swapped
        swapped = false
        for i in eachindex(result)[2:end]
            if result[i-1] > result[i]
                result[i-1], result[i] = result[i], result[i-1]
                swapped = true
            end
        end
    end
    return result
end
"""
sc(s)
```

Here, we implemented the algorithm for a vector that contains the elements of
type `A`. In this case it is just a sub-type (`<:`) of `Flt` (an alias for
`Float64`) or `Int` (`Union{Flt, Int}`). We started by `copy`ing the original
vector to `result` and setting a variable named `swapped`. We will stop our
sorting algorithm once there was no swap during the previous traversal of the
whole vector (`swapped` in `while` is initially `false`, but notice that it may
be reset to `true` in the `for` loop). We search through the vector starting
from its second element (`i in eachindex(result)[2:end]`). Every time we compare
the two nearby elements (`result[i-1]` vs. `result[i]`). If the elements aren't
in a desired order (`if result[i-1] > result[i]`) we just swap them with each
other (`result[i-1], result[i] = result[i], result[i-1]`) and set the `swapped`
flag to `true`. Once we finish we return the result.

Let's see how we did.

```jl
s = """
[47, 15, 23, 99, 4] |> bs,
[47.3, 23.2, 47.2] |> bs
"""
sco(s)
```

If you want to better visualize how the algorithm works, you may place `println`
or [\@show](https://docs.julialang.org/en/v1/base/base/#Base.@show) constructs
in a few places inside the function, e.g.

```
function bs(v::Vec{A})::Vec{A} where A<:Union{Flt, Int}
    result::Vec{A} = copy(v)
    swapped::Bool = true
    i::Int = 0
    while swapped
        i += 1
        @show i
        swapped = false
        for i in eachindex(result)[2:end]
            if result[i-1] > result[i]
                result[i-1], result[i] = result[i], result[i-1]
                swapped = true
            end
            @show result, swapped
        end
    end
    return result
end
```

Which prints:

```
[0.75, 0.25, 0.5] |> bs

# printout
i = 1
(result, swapped) = ([0.25, 0.75, 0.5], true)
(result, swapped) = ([0.25, 0.5, 0.75], true)
i = 2
(result, swapped) = ([0.25, 0.5, 0.75], false)
(result, swapped) = ([0.25, 0.5, 0.75], false)
```

For our next try we will go with the
[quicksort](https://en.wikipedia.org/wiki/Quicksort) algorithm. Here, I'll try
to implement it from memory based on the algorithm I once saw in "Learn You a
Haskell for Great Good!" by Miran Lipovača. Of course, I'll try to adjust it for
Julia syntax.

```jl
s = """
# sorts in ascending order
function qs(v::Vec{Int})::Vec{Int}
    if isempty(v)
        return []
    else
        head, tail... = v
		# or: head::Int, tail::Vec{Int}... = v
        smallerElts::Vec{Int} = filter((<)(head), tail)
        greaterEqElts::Vec{Int} = filter((>=)(head), tail)
        return [qs(smallerElts); head; qs(greaterEqElts)]
    end
end
"""
sc(s)
```

To do so we choose a so called pivot element (`head`) that for simplicity is
always the first element in the vector (`v`). Next, we take the remaining part
of the vector (`tail`). The `head, tail... = v` is a [destructuring
assignment](https://docs.julialang.org/en/v1/manual/functions/#destructuring-assignment)
that puts the first elt of `v` to `head` variable and all the remaining elements
to `tail` (if `v` is made of one element, then `tail` is `[]`). Anyway, we
separate `tail` elements into the ones that are smaller (`smallerElts`) and
greater than or equal to (`greaterEqElts`) our pivot element (`head`). The above
is done with `filter` and [partial function
application](https://bkamins.github.io/julialang/2024/02/23/fix.html). Once we
got it we use recursion (e.g. `qs(unsorted_smaller_elts)` in `return`) and
vector concatenation (`[vector_or_elt; vector_or_elt; vector_or_elt]`).

Let's see how it works.

```jl
s = """
[47, 15, 23, 99, 4] |> qs
"""
sco(s)
```

Looks good. OK, in case the above was too great of a squeeze, let's try to make
it a bit less [functional](https://en.wikipedia.org/wiki/Functional_programming)
(Haskell is a purely functional programming language) and a bit more
[imperative](https://en.wikipedia.org/wiki/Imperative_programming).

```jl
s1 = """
function qs(v::Vec{Int})::Vec{Int}
    if isempty(v)
        return []
    else
        firstElt::Int = v[1]
        otherElts::Vec{Int} = v[2:end]
        smallerElts::Vec{Int} = filter(elt -> elt < firstElt, otherElts)
        greaterEqElts::Vec{Int} = filter(elt -> elt >= firstElt, otherElts)
        return [qs(smallerElts); firstElt; qs(greaterEqElts)]
    end
end
"""
sc(s1)
```

Once again, we choose a so called pivot element (`firstElt`) that for simplicity
is always the first element of a vector. Next, we take the remaining elements
(`otherElts`) and separate them into the elements that are smaller
(`smallerElts`) and greater than or equal to (`greaterEqElts`) our pivot element
(`firstElt`). The above is done with `filter` and an [anonymous
function](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions). Once
we got it we use recursion (e.g. `qs(unsorted_smaller_elts)` in `return`) and
vector concatenation (`[vector_or_elt; vector_or_elt; vector_or_elt]`).

Just a small test to make sure it still works as intended.

```jl
s1 = """
[47, 15, 23, 99, 4] |> qs
"""
sco(s1)
```

Flawless victory, but we are still unable to sort the numbers in alphabetical
order. Let's fix that by modifying our `qs`.

```jl
s = """
# by - fn(A) -> B; is applied to every elt of v before sorting
# lt - fn(B, B) -> Bool; compares pairs of elts after 'by' was applied
function qs(v::Vec{A},
            by::Function=identity,
            lt::Function=<)::Vec{A} where A
    if isempty(v)
        return []
    else
        firstElt::A = v[1]
        otherElts::Vec{A} = v[2:end]
        smallerElts::Vec{A} = filter(
            elt -> lt(by(elt), by(firstElt)),
            otherElts
        )
        greaterEqElts::Vec{A} = filter(
            elt -> !lt(by(elt), by(firstElt)),
            otherElts
        )
        return [
            qs(smallerElts, by, lt);
            firstElt;
            qs(greaterEqElts, by, lt)
        ]
    end
end
"""
sc(s)
```

Here, we added two more positional arguments to `qs`: 1) `by` which is a
function applied to every element of the vector (`v`) before the sorting; 2)
`lt` - a comparator function (`lt` - less than, `!lt` - negation of `lt`) that
compares our pivot element (`firstElt`) with all the other elements
(`otherElts`). The comparison occurs after `by` was applied to all the elements
of `v` (`by(elt)` and `by(firstElt)` in `filter`). Notice, that in Julia we can
compare `x` and `y` (that contain, e.g. two numbers) like this `x < y` (operator
between two arguments) or like that `<(x, y)` (function accepting two
arguments). The latter form was applied in `lt(by(elt), by(firstElt))`
above. Anyway, the names `by` and `lt` were inspired by the names of the
[keyword
arguments](https://docs.julialang.org/en/v1/devdocs/functions/#Keyword-arguments)
in [Base.sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort). The
default function for `by` is
[identity](https://docs.julialang.org/en/v1/base/base/#Base.identity) (returns
its argument unchanged) and the default function for `lt` is
[Base.:<](https://docs.julialang.org/en/v1/base/math/#Base.:%3C).

Let's see how we did:

```jl
s = """
[0.75, 0.25, 0.5] |> qs,
['c', 'b', 'a', 'd'] |> qs
"""
sco(s)
```

And now for the alphabetical sort (`getEngNumeral` was a solution for the
problem in @sec:cheque_problem. Here, we passed it without `by=` because in `qs`
it is a positional argument).


```jl
s = """
qs(collect(1:10), getEngNumeral)
"""
sco(s)
```

The above should work similar to the built-in `sort` (here we use
`by=getEngNumeral` because that's how you pass keyword arguments to a function).

```jl
s = """
qs([0.75, 0.25, 0.5]) == sort([0.75, 0.25, 0.5]),
qs(['c', 'b', 'a', 'd']) == sort(['c', 'b', 'a', 'd']),
qs(collect(1:10), getEngNumeral) == sort(1:10, by=getEngNumeral)
"""
sco(s)
```
