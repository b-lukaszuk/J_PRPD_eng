# Roman Numerals {#sec:roman_numerals}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/roman_numerals)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:roman_numerals_problem}

Every now and then we encounter some Roman numerals written on an old building's
wall or a book's page. Your job is to refresh your knowledge about the
numerals, e.g. by reading [this Wikipedia's
entry](https://en.wikipedia.org/wiki/Roman_numerals), and write a two way
converter, for instance in the form of `getRoman(arabic::Int)::Str` and
`getArabic(roman::Str)::Int` functions. Below you will find two sets of parallel
numbers (based on the Wikipedia's page) so that you can test your results (your
solution should work correctly for the numbers in range [1-3999]).

```jl
s = """
arabicTest = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
              11, 12, 39, 246, 789, 2421, 160, 207, 1009, 1066,
              3999, 1776, 1918, 1944, 2025,
			  1900, 1912]
romanTest = ["I", "II", "III", "IV", "V",
             "VI", "VII", "VIII", "IX", "X",
             "XI", "XII", "XXXIX", "CCXLVI", "DCCLXXXIX",
             "MMCDXXI", "CLX", "CCVII", "MIX", "MLXVI",
             "MMMCMXCIX", "MDCCLXXVI", "MCMXVIII", "MCMXLIV", "MMXXV",
             "MCM", "MCMXII"]
"""
sc(s)
```

Good luck.

## Solution {#sec:roman_numerals_solution}

Let's start with a simple mapping between some key Roman numerals and their
Arabic counterparts.

```jl
s = """
ROMAN_2_ARABIC = [("M", 1000), ("CM", 900),
                ("D", 500), ("CD", 400),
                ("C", 100), ("XC", 90),
                ("L", 50), ("XL", 40),
                ("X", 10), ("IX", 9), ("V", 5),
                ("IV", 4), ("I", 1)]
"""
replace(sc(s), r"\bROMAN" => "const ROMAN")
```

The mapping is defined with (`const`) keyword to signal that we do
not wish to change it throughout the program execution. Moreover, we used a
vector of tuples, not a dictionary, since we want to preserve the (descending)
order of the pairs of values. Notice, that we incluced the key landmarks
of subtractive notation (e.g. `("CM", 900)` or `("IV", 4)`).

> Note. Using `const` with mutable containers like vectors or dictionaries
> allows to change their contents later on, e.g., with `push!`. So the `const`
> used here is more like a convention, a signal that we do not plan to change
> the containers in the future. If we really wanted an immutable container then
> we should consider a(n) (immutable) tuple. Anyway, some programming languages
> suggest that `const` names should be declared using all uppercase characters
> to make them stand out. Here, I follow this convention.

Now, we are ready to take the next step.

```jl
s = """
function getRoman(arabic::Int)::Str
    @assert 0 < arabic < 4000
    roman::Str = ""
    for (r, a) in ROMAN_2_ARABIC
        while(arabic >= a)
            roman *= r
            arabic -= a
        end
    end
    return roman
end
"""
sc(s)
```

We will build our Roman numeral bit by bit starting from an empty string
(`roman::Str = ""`). For that we traverse all our Roman and Arabic landmarks
(`for (r, a) in ROMAN_2_ARABIC`). For each of them (starting from the highest number),
we check if the currently examined Arabic landmark (`a`) is lower than the
Arabic number we got to translate (`arabic`). As long as it is
(`while(arabic >= a)`) we append the parallel Roman landmark (`r`) to our
solution (`roman *= r`) and subtract the Arabic landmark (`a`) from our Arabic
number (`arabic -= a`). Once we are done we return the result.

> Note. To better understand the above code you may read about the `while` loop
> in [the docs](https://docs.julialang.org/en/v1/base/base/#while) and use
> [show](https://docs.julialang.org/en/v1/base/base/#Base.@show) macro to have a
> sneak peak how the variables in the loop change. If you ever accidentally
> write an infinite `while` loop you may try to break the program execution by
> pressing [Ctrl+C](https://en.wikipedia.org/wiki/Control-C) in your
> terminal/command line.

Time for a minitest (go ahead pick a number and, in your head or on a piece of
paper, follow the function's execution).

```jl
s = """
getRoman.(1:10)
"""
sco(s)
```

OK, time for a bigger test.

```jl
s = """
getRoman.(arabicTest) == romanTest
"""
sco(s)
```

Looks alright.

Time to write our `getArabic` function. For that we will have to break a Roman
numeral into tokens (from left to right) that we will use to build up an Arabic
number.

```jl
s = """
ROMAN_TOKENS = map(first, ROMAN_2_ARABIC)
# equivalent to
# ROMAN_TOKENS = map(tuple -> tuple[1], ROMAN_2_ARABIC)

function getTokenAndRest(roman::Str)::Tuple{Str, Str}
    if length(roman) <= 1
        return (roman, "")
    elseif roman[1:2] in ROMAN_TOKENS
        return (roman[1:2], string(roman[3:end]))
    else
        return (string(roman[1]), string(roman[2:end]))
    end
end

function getTokens(roman::Str)::Vec{Str}
    curToken::Str = ""
    allTokens::Vec{Str} = []
    while (roman != "")
        curToken, roman = getTokenAndRest(roman)
        push!(allTokens, curToken)
    end
    return allTokens
end
"""
replace(sc(s), r"\bROMAN_TOKENS =" => "const ROMAN_TOKENS =")
```

First, we extract `ROMAN_TOKENS` with `map` and
[first](https://docs.julialang.org/en/v1/base/collections/#Base.first). Next,
we use `getTokenAndRest` to split a Roman numeral into a key token (first on the
left, either one or two characters long) and the rest of the
numeral. The `string(sth)` part makes sure we always return a string and not a
character. Anyway, based on it (`getTokenAndRest`) we split a Roman numeral into
a vector of tokens with `getTokens`. Now, we are ready to write our `getArabic`.

```jl
s = """
function getVal(lookup::Vec{Tuple{Str, Int}}, key::Str, default::Int)::Int
    for (k, v) in lookup
        if k == key
            return v
        end
    end
    return default
end

function getArabic(roman::Str)::Int
    tokens::Vec{Str} = getTokens(roman)
    sum::Int = 0
    for curToken in tokens
        sum += getVal(ROMAN_2_ARABIC, curToken, 0)
    end
    return sum
end
"""
sc(s)
```

Notice, that before we moved to `getArabic` we wrote `getVal` that will provide
us with an Arabic number for a given Roman numeral token. The above was not
strictly necessary, as we could have just use the built-in
[get](https://docs.julialang.org/en/v1/base/collections/#Base.get) for that
purpose (e.g. with `get(Dict(ROMAN_2_ARABIC), key, default)`). Anyway, to get the
Arabic number for a given Roman numeral (`roman`), first we split it into a
vector of `tokens` and traverse them one by one (`curToken`) with the `for`
loop. We translate `curToken` to an Arabic numeral and add it to `sum` which we
return once we are done.

Again, let's go with a minitest (go ahead pick a number and, in your head or on
a piece of paper, follow the function's execution).

```jl
s = """
getArabic.(["I", "II", "III", "IV", "V", "VI", "VII", "VIII"])
"""
sco(s)
```

Finally, a bigger test.

```jl
s = """
getArabic.(romanTest) == arabicTest
"""
sco(s)
```

And another one.

```jl
s = """
getArabic.(getRoman.(arabicTest)) == arabicTest
"""
sco(s)
```

I don't know about you, but to me the results are satisfactory.
