# Stem and Leaf Plot {#sec:stem_and_leaf}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/stem_and_leaf)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:stem_and_leaf_problem}

In statistics a useful technique used to visualize the distribution of data is a
[histogram](https://en.wikipedia.org/wiki/Histogram). A bit less popular,
although easier to implement with text display is [stem and leaf
plot](https://en.wikipedia.org/wiki/Stem-and-leaf_display).

So here is a task for you:

- read the Wikipedia's description of how the plot is constructed
- write the function that displays stem and leaf plot for positive integers
- extend it to work also with negative integers
- extend it to work also with floats

As a minimal test, make sure it works correctly on the examples from the
[Wikipedia's web page](https://en.wikipedia.org/wiki/Stem-and-leaf_display),
i.e.

```jl
s = """
# prime numbers below 100
stemLeafTest1 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
                41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
# example from the Construction section
stemLeafTest2 = [44, 46, 47, 49, 63, 64, 66, 68, 68, 72, 72, 75,
                76, 81, 84, 88, 106]
# another example from the Construction section
stemLeafTest3 = [-23.678758, -12.45, -3.4, 4.43, 5.5, 5.678,
                16.87, 24.7, 56.8]
"""
sc(s)
```

Notice that if you broaden the range of input numbers (e.g. by appending 300 or
400, to `stemLeafTest1`) you will still get a printout, but the plot won't be so
pretty.

## Solution {#sec:stem_and_leaf_solution}

Let's start with a helper function that returns the number of characters that
compose a number.

```jl
s = """
function howManyChars(num::Int)::Int
    return num |> string |> length
end
"""
sc(s)
```

The function is quite simple, it sends (`|>`) a number (`num`) to `string`
(converts a number to its textual representation) and redirects the result
(`|>`) to `length`. I find this form clearer that the equivalent
`length(string(num))` or `string(num) |> length` or `(length ∘ string)(num)`
(`∘` is a [function composition
operator](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping)
that you obtain by typing `\circ` and pressing Tab).

Time for a test run.

```jl
s = """
map(howManyChars, [5, -8, -11, 303])
"""
sco(s)
```

Appears to be working fine.

Now let's write a function that takes a vector of integers and returns the
number of characters in the longest of them (we will need it to determine the
width of the stem later on).

```jl
s = """
function getMaxLengthOfNum(nums::Vec{Int})::Int
    maxLen::Int = map(howManyChars, nums) |> maximum
    return max(2, maxLen)
end
"""
sc(s)
```

> Note. Instead of `map(howManyChars, nums)` above we could have just used
> `map(length ∘ string, nums)`. This would save us some typing (no need to
> define `howManyChars` in the first place), but made the code a bit more
> cryptic at first read.

Again, a piece of cake, we just use `map` to apply `howManyChars` to every
number in a vector (`nums`) and get the length of the longest number by
sending (`|>`) the lengths to `maximum`. Notice, that the function doesn't
return the expected `maxLen`. This is because in a moment, we will write
`getStemAndLeaf(num::Int, maxLenOfNum::Int)` that brakes a number into two
parts: stem and leaf. It will require `maxLenOfNum` to be at least 2 (so that at
least one digit serves as a stem and one as a leaf), hence we `return max(2,
maxLen)`.

```jl
s = """
function getStemAndLeaf(num::Int, maxLenOfNum::Int)::Tuple{Str, Str}
    @assert maxLenOfNum > 1 "maxLenOfNum must be greater than 1"
    @assert howManyChars(num) <= maxLenOfNum
		"character count in num must be <= maxLenOfNum"
    numStr::Str = lpad(abs(num), maxLenOfNum, "0")
    stem::Str = numStr[1:end-1] |> string
    leaf::Str = numStr[end] |> string
    stem = parse(Int, stem) |> string #1
    stem = num < 0 ? "-" * stem : stem #2
    stem = lpad(stem, maxLenOfNum-1, " ") #3
    return (stem, leaf)
end
"""
sc(s)
```

We begin with `lpad`. This function converts its first input (`abs(num)`) to
string of a given length (`maxLenOfNum`). It adds a padding (`"0"`) to the left
side of the result (if necessary) in order to obtain the string with a desired
number of characters. Next, we proceed to obtain the `stem` which contains all
the characters from `numStr`, except the last one (`end-1`). The `|> string`
makes sure that the end result is `Str` (since, e.g. `stem` from `"21"` would be
`'2'` which is of type `Char`). Similarly, we produce `leaf` by taking the last
character of `numStr`. We could stop here, and it would likely work fine for a
positive integer. However, handling broader range of inputs (`num` and
`maxLenOfNum`) requires some further `stem` processing. Hence the lines
designated with `#1-#3` that were added in later iterations of
`getStemAndLeaf`.`#1` removes superfluous 0s from the left side of the string
(e.g. `"001"` becomes `"1"` and `"00"` becomes `"0"`). `#2` adds `"-"` sign if
the input (`num`) was negative. `#3` aligns the text (`stem`) to the right. It
does so by adding spaces (`" "`) to the left site of `stem`. All that's left to
do is to `return` our `stem` and `leaf` and see how it works for some exemplary
inputs.

```jl
s = """
Dict(n => getStemAndLeaf(n, 3) for n in [-12, -3, 3, 8, 10, 145])
"""
sco(s)
```

Time to write `getLeafCounts` a function that for a vector of numbers returns a
mapping (`Dict`) between stems (keys) and leaves (values).

```jl
s = """
# returns Dict{stem, [leaves]}
function getLeafCounts(nums::Vec{Int},
	maxLenOfNum::Int)::Dict{Str, Vec{Str}}
    @assert length(unique(nums)) > 1 "numbers musn't be the same"
    counts::Dict{Str, Vec{Str}} = Dict()
    for num in nums
        stem, leaf = getStemAndLeaf(num, maxLenOfNum) # for's local vars
        if haskey(counts, stem)
            counts[stem] = push!(counts[stem], leaf)
        else
            counts[stem] = [leaf]
        end
    end
    return counts
end
"""
sc(s)
```

First, we initialize an empty `Dict` (`counts`) that will hold our result. Next,
we brake each number (`for num in nums`) into `stem` and `leaf` parts. If the
`counts` already contains such a `stem` (`haskey(counts, stem)`), then we add
the `leaf` to the vector of already existing leaves (`push!(counts[stem],
leaf)`). Otherwise (`else`), we add a `leaf` as a 1-element vector (`[leaf`])
for a given `stem`. Finally, we return the `counts`.

Let's see how it works.

```jl
s = """
# prime numbers below 100
primesLeafCounts = getLeafCounts(
	[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
		53, 59, 61, 67, 71, 73, 79, 83, 89, 97],
	2
)
"""
sco(s)
```

Looks, alright. Time to pretty print the result. First, let's get a formatted
row.

```jl
s = """
function getStemLeafRow(key::Str, leafCounts::Dict{Str, Vec{Str}})::Str
    row::Str = key * "|"
    if haskey(leafCounts, key)
        row *= sort(leafCounts[key]) |> join
    end
    return row * "\n"
end
"""
replace(sc(s), Regex("\"\n\"") => "\"\\n\"")
```

We define our `row` as a string that contains the `key` and separator. If our
`leafCounts` contains a given `key` then we append its sorted values
concatenated together with `join` function (e.g., `["1", "1", "3"] |> join`
becomes `"113"`). We return `row` with a newline character (`\n`).

Time for the whole stem and leaf plot.

```jl
s = """
function getStemLeafPlot(nums::Vec{Int})::Str
    maxLenOfNum::Int = getMaxLengthOfNum(nums)
    leafCounts::Dict{Str, Vec{Str}} = getLeafCounts(nums, maxLenOfNum)
    low::Int, high::Int = extrema(nums)
    testedStems::Dict{Str, Bool} = Dict()
    result::Str = ""
    for num in low:1:high
        stem, _ = getStemAndLeaf(num, maxLenOfNum)
        if haskey(testedStems, stem)
            continue
        end
        result *= getStemLeafRow(stem, leafCounts)
        testedStems[stem] = true
    end
    return result
end
"""
sc(s)
```

At the onset, we define a few variables. Some of them deserve a short
explanation. `low` and `high` are the two `extrema` (minimum and maximum) of our
numbers (`nums`). `testedStems` will contain the keys from `leafCounts`,
i.e. the stems from our stem-leaf plot that rows has been already
obtained. Next, we use `for` loop to travel through all the numbers in our range
(`low` to `high`). For each tested number (`num`) we get its `stem`. If the
`stem` was already obtained (`if haskey`) we `continue` to another `for` loop
iteration. Otherwise, we add the row to our `result`
(`result *= getStemLeafRow`) and insert the `stem` among the already visited
(`testedStems[stem] = true`). When we finish we return the whole stem-leaf-plot
(`return result`).

And that's it. Let's see how it works on [Wikipedia's
examples](https://en.wikipedia.org/wiki/Stem-and-leaf_display). First, prime
numbers below 100:

```
getStemLeafPlot(stemLeafTest1)
```

```
0|2357
1|1379
2|39
3|17
4|137
5|39
6|17
7|139
8|39
9|7
```

Now, the numbers from the Construction section:

```
getStemLeafPlot(stemLeafTest2)
```

```
 4|4679
 5|
 6|34688
 7|2256
 8|148
 9|
10|6
```

All that's left to do is to adjust our function for the example with floats.

```jl
s = """
function getStemLeafPlot(nums::Vec{Flt})::Str
    ints::Vec{Int} = round.(Int, nums)
    return getStemLeafPlot(ints)
end
"""
sc(s)
```

And voila:

```
getStemLeafPlot(stemLeafTest3)
```

```
-2|4
-1|2
-0|3
 0|466
 1|7
 2|5
 3|
 4|
 5|7
```

It appears to be working as intended so I think we can finish here.
