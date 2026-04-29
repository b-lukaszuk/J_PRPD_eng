# Leap Year {#sec:leap_year}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/leap_year)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:leap_year_problem}

As you probably know an astronomical year is slightly more than 365 days
(roughly 365.2425 days). For that reason [the Gregorian
calendar](https://en.wikipedia.org/wiki/Gregorian_calendar) got common years
(365 days each) and [leap years](https://en.wikipedia.org/wiki/Leap_year) (366
days each).

You task is to write a function that detects whether a given year is a leap year
(according to the Gregorian calendar). Feel free to test it, e.g. on the
following input: [1792, 1859, 1900, 1918, 1974, 1985, 2000, 2012] of which only
1792, 2000, and 2012 are leap years.

## Solution {#sec:leap_year_solution}

Let's start with the algorithm, as stated in [the Wikipedia's
page](https://en.wikipedia.org/wiki/Gregorian_calendar):

> The rule for leap years is that every year divisible by four is a leap year,
> except for years that are divisible by 100, except in turn for years also
> divisible by 400.

Nothing more, nothing less. Time to translate it into Julia's code.

```jl
s = """
function isLeap(yr::Int)::Bool
    @assert 0 < yr < 4001 "yr must be in range [1-4000]"
    divisibleBy4::Bool = yr % 4 == 0
    gregorianException::Bool = (yr % 100 == 0) && (yr % 400 != 0)
    if !divisibleBy4
        return false
    else
        return !gregorianException
    end
end
"""
sc(s)
```

The powerhouse of our function is `%` (modulo operator) that returns the
reminder of the division. If a number `x` is evenly divided by a number `y` (`x
% y`) the reminder is equal to zero (`== 0`). Otherwise (when `x % y != 0`) the
`x` cannot be evenly divided by `y`. Although not strictly necessary, we added a
mnemonic names for the tested conditions (`divisibleBy4` and
`gregorianException`), which should make the code more readable. Anyway, if a
year (`yr`) is not divisible by 4 (`!divisibleBy4`) then it is a common year.
Otherwise (`else`) if the the year fulfills the exception rule
(`gregorialException` is `true`) it is not a leap year (hence we negate `!`
`gregorianException`, because `!true` is `false`). If a year (`yr`) does not
meet the exception criteria (`gregorianException` is `false`) it is a common
year (we negate `false`, so we get `true`).

Actually, we can get rid of the `if`-`else` condition by using `&&` (logical
and) and its short circuiting property.

```jl
s1 = """
function isLeap(yr::Int)::Bool
    @assert 0 < yr < 4001 "yr must be in range [1-4000]"
    divisibleBy4::Bool = yr % 4 == 0
    gregorianException::Bool = (yr % 100 == 0) && (yr % 400 != 0)
    return divisibleBy4 && !gregorianException
end
"""
sc(s1)
```

When `divisibleBy4` is `false` the and operator (`&&`) skips the evaluation of
its second argument (short circuiting) and returns `false`. Otherwise,
(`divisibleBy4` is `true`) `!gregorianException` is evaluated and it becomes the
result of the function. 

Time for a simple test.

```jl
s = """
yrs = [1792, 1859, 1900, 1918, 1974, 1985, 2000, 2012]
filter(isLeap, yrs)
"""
sco(s)
```

The `filter` function applies `isLeap` to each element of `yrs` and returns only
those for which the result is `true`.

Since the solution was pretty easy let's add some more tests to let our fingers
cool down slowly. If you read [the Wikipedia's
page](https://en.wikipedia.org/wiki/Gregorian_calendar) carefully then you know
that for every 400 years period we got 303 regular years and 97 leap
years. Let's see if that rule holds.

```jl
s = """
function runTestSet()::Int
    startYr::Int = 0
    endYr::Int = 0
    numLeapYrs::Int = 0
    for i in 1:3601
        startYr = i
        endYr = i + 400 - 1
        numLeapYrs = filter(isLeap, startYr:endYr) |> length
        if numLeapYrs != 97
            return 1
        end
    end
    return 0 # C-like return value
end

runTestSet()
"""
sco(s)
```

Here we tested different time periods (each spanning 400 years). Notice that
last such a period starts in the year `3601`, since our function handles inputs
in the range [1 - 4000] and `length(3600:4000)` is actually equal
to 401. Anyway, for each of the periods, we counted the number of leap years
(`numLeapYrs`) with `filter` and `length`. If `numLearpYrs` differs from `97`,
we return `1` right away (and skip other checks). Otherwise (once all the
periods passed the tests) we return `0`. The above is a convention met in C
programming language (in the `main` function). It is sufficient for our
simplistic case, however, for more serious applications you should follow the
testing advice contained in [the
docs](https://docs.julialang.org/en/v1/stdlib/Test/).
