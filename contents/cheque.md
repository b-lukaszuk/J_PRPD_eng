# Cheque {#sec:cheque}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/cheque)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:cheque_problem}

Every now and then it comes in handy to be able to write down an [English
numeral](https://en.wikipedia.org/wiki/English_numerals) with the words. Case in
point would be to write a sum of money on a cheque or to display it in a finance
(perhaps bank) app. So here is a task for you. Write a program in Julia that for
any number let's say in the range of 1 to 999,999 returns its transcription with
words. You may handle only integers.

## Solution {#sec:cheque_solution}

We begin by defining a few constants that will be useful later on.

```jl
s = """
UNITS_AND_TEENS = Dict(1 => "one",
                             2 => "two", 3 => "three", 4 => "four",
                             5 => "five", 6 => "six", 7 => "seven",
                             8 => "eight", 9 => "nine", 10 => "ten",
                             11 => "eleven", 12 => "twelve",
                             13 => "thirteen", 14 => "fourteen",
                             15 => "fifteen", 16 => "sixteen",
                             17 => "seventeen", 18 => "eighteen",
                             19 => "nineteen")

TENS = Dict(2 => "twenty", 3 => "thrity",
                  4 => "forty", 5 => "fifty", 6 => "sixty",
                  7 => "seventy", 8 => "eigthy", 9 => "ninety")
"""
replace(sc(s), r"\bUNITS" => "const UNITS", r"\bTENS " => "const TENS ")
```

> Note. Using `const` with mutable containers like vectors or dictionaries
> allows to change their contents later on, e.g., with `push!`. So the `const`
> used here is more like a convention, a signal that we do not plan to change
> the containers in the future. If we really wanted an immutable container then
> we should consider a(n) (immutable) tuple. Anyway, some programming languages
> suggest that `const` names should be declared using all uppercase characters
> to make them stand out. Here, I follow this convention.

The above are just mappings between the necessary basic key ingredients of our
number soup. Let's use them to get the transcript for numbers in the range of 1
to 99.

```jl
s = """
function getEngNumeralUpto99(n::Int)::Str
    @assert 1 <= n <= 99 "n must be in range [1-99]"
    if n < 20
        return UNITS_AND_TEENS[n]
    end
    t::Int, u::Int = divrem(n, 10) # t - tens, u - units
    result::Str = TENS[t]
    if u != 0
        result *= "-" * UNITS_AND_TEENS[u]
    end
    return result
end
"""
sc(s)
```

Whenever a number (`n`) is below 20 (`if n < 20`) we just return its
representation from the `UNITS_AND_TEENS` dictionary. Alternatively, for `n` in
the `TENS`, first we obtain the tens (`t`) and units (`u`) part.
[divrem](https://docs.julialang.org/en/v1/base/math/#Base.divrem) is a
combination of `div` (an integer division) and `rem` (a reminder after the
division). We use it, to obtain the transcript for the TENS (`TENS[t]`). It
becomes our `result` to which we attach the transcript for units separated by a
hyphen (`"-" * UNITS_AND_TEENS[u]`), but only if the unit is different than zero
(`if u != 0`).

Time for a test ride.

```jl
s = """
(
	getEngNumeralUpto99.([5, 9, 11, 13, 20, 21]),
	getEngNumeralUpto99.([25, 32, 58, 64, 66]),
	getEngNumeralUpto99.([79, 83, 95, 99])
)
"""
replace(sco(s), "], " => "],\n")
```

Good. It appears we got that one out of our way. Let's move on to something
bigger.

```jl
s = """
function getEngNumeralUpto999(n::Int)::Str
    @assert 1 <= n <= 999 "n must be in range [1-999]"
    if n < 100
        return getEngNumeralUpto99(n)
    end
    h::Int, t::Int = divrem(n, 100) # h - hundreds, t - tens
    result::Str = getEngNumeralUpto99(h) * " hundred"
    if t != 0
        result *= " and " * getEngNumeralUpto99(t)
    end
    return result
end
"""
sc(s)
```

This time we deal with all the integers below one thousand.
The previously defined `getEngNumeralUpto99` is an important building block of
that new function. If a number (`n`) is smaller than 100 (`if n < 100`) we just
transcribe it as we did in the previous code snippet
(`return getEngNumeralUpto99(n)`).
Otherwise we split it into hundreds (`h`) and TENS part (`t`, actually it may
also contain units and teens). We start building our `result` by transcribing
the hundreds part (`result::Str = getEngNumeralUpto99(n) * " hundred"`). When
appropriate (`t != 0`) we append the transcript for the TENS separated with
`"and"` (British English convention) to our `result`.

Time for a test.

```jl
s = """
(
	getEngNumeralUpto999.([9, 13, 20, 66]),
	getEngNumeralUpto999.([101, 109, 110]),
	getEngNumeralUpto999.([320, 400, 500])
)
"""
replace(sco(s), "], " => "],\n")
```

Since the previous part was so easy, there's not reason to linger. Time for our
final leap.

```jl
s = """
function getEngNumeralBelow1M(n::Int)::Str
    @assert 1 <= n <= 999_999 "n must be in range [1-999,999]"
    if n < 1000
        return getEngNumeralUpto999(n)
    end
    t::Int, h::Int = divrem(n, 1000) # t - thousands, h - hundreds
    result::Str = getEngNumeralUpto999(t) * " thousand"
    if h == 0
        return result
    elseif h < 100
        result *= " and "
    else
        result *= ", "
    end
    result *= getEngNumeralUpto999(h)
    return result
end
"""
sc(s)
```

This time we also use our previously defined function (`getEngNumeralUpto999`)
as an integral part of the bigger, more general solution. When a number (`n`)
is small (`if n < 1000`) we write it down as we used to
(`return getEngNumeralUpto999(n)`). Otherwise, we split it (`n`) to the
thousands (`t`) and the hundreds (`h`) parts. Next, we build our `result` for
the thousands (`getEngNumeralUpto999(t) * " thousand`).
When the hundreds part is 0 (`if h == 0`) we just return our `result`. If the
hundreds part is small (`h < 100`) we add the conjunction `" and "`, otherwise
(large hundreds part), we separate the following words with `", "`. Once again,
we finish by using `getEngNumeralUpto999(h)` to transcribe the remaining part.

Let's see our creation at work.

```jl
s = """
(
	getEngNumeralBelow1M.([5, 9, 13, 21, 40, 95]),
	getEngNumeralBelow1M.([101, 320, 500]),
	getEngNumeralBelow1M.([1_800]),
	getEngNumeralBelow1M.([96_779]),
	getEngNumeralBelow1M.([180_000]),
	getEngNumeralBelow1M.([889_308])
)
"""
replace(sco(s), "], " => "],\n")
```

Mission, completed. We wrote three functions that allow us to write down any
number we want in the range [1-999,999]. Still, you could argue that there is
some code duplication. If that bothers you, you may try to shorten the solution
to something like:

```jl
s = """
function getEngNumeral(n::Int)::Str # uses recursion
    @assert 0 < n < 1e6 "n must be in range (0-1e6)"
    major::Int, minor::Int = 0, 0
    if n < 20
        return UNITS_AND_TEENS[n]
    elseif n < 100
        major, minor = divrem(n, 10)
        return TENS[major] * (
            minor == 0 ? "" : "-" * UNITS_AND_TEENS[minor]
        )
    elseif n < 1000
        major, minor = divrem(n, 100)
        return getEngNumeral(major) * " hundred" * (
            minor == 0 ? "" : " and " * getEngNumeral(minor)
        )
    else # < 1e6 due to @assert above
        major, minor = divrem(n, 1_000)
        return getEngNumeral(major) * " thousand" * (
            minor == 0 ? "" :
            minor < 100 ? " and " * getEngNumeral(minor) :
            ", " * getEngNumeral(minor)
        )
    end
end
"""
sco(s)
```

This allowed us to reduce the number of lines of code roughly by half, while
maintaining the functionality.

```jl
s = """
(
	getEngNumeral.([5, 9, 13, 21, 40, 95]),
	getEngNumeral.([101, 320, 500]),
	getEngNumeral.([1_800]),
	getEngNumeral.([96_779]),
	getEngNumeral.([180_000]),
	getEngNumeral.([889_308])
)
"""
replace(sco(s), "], " => "],\n")
```
