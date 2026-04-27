# Shift {#sec:shift}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/shift)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:shift_problem}

Imagine that one day you received a mysterious e-mail to your inbox. At first
you thought it was a spam, but it just looks like a complete gibberish. Upon
more detailed inspection it turned out that the text got some regularity to it.
So it might be a coded message. Just in case you saved it as `trarfvf.txt` ([see
the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/shift)),
since `trarfvf` was the title of the message.

Now, a simple method to code something is to use a shift cipher (see
@fig:codingDiscs).

![Coding Discs. The outer disc contains the original alphabet. The inner disc
contains the alphabet shifted by 2
characters](./images/codingDiscs.png){#fig:codingDiscs}

To that end you cut two discs out of paper with all the characters from the
alphabet on them. You shift the inner disk by a certain number of fields (+2 in
@fig:codingDiscs). In order to encode a letter you move the red tick around to
that character (in the outer circle). Next you read the encoded letter in the
inner circle (as pointed by the tick). If a letter or a symbol from the original
text is not in the disk you just retype it as it is.

This way, coding the phrase "JULIA :)" with shift +2 from @fig:codingDiscs would
give us "LWNKC :)"

Anyway, here is a task for you. Use a [frequency
analysis](https://en.wikipedia.org/wiki/Letter_frequency) to figure out the
shift (rotation) used to code the message found in `trarfvf.txt` (~31 KiB).

## Solution {#sec:shift_solution}

Let's approach the problem step by step.

First let's read the file's contents (`open` and `read` were discussed in
@sec:transcription_solution), `uppercase` all the characters (compare with
@sec:translation_solution) and preserve only letters from the English alphabet
(`filter`).

```jl
s = """
# the file is roughly 31 KiB
# if necessary adjust the filePath
codedTxt = open("./code_snippets/shift/trarfvf.txt") do file
    read(file, Str)
end

codedTxt = uppercase(codedTxt)

function isUppercaseLetter(c::Char)::Bool
    return c in 'A':'Z'
end

codedTxt = filter(isUppercaseLetter, codedTxt)
first(codedTxt, 20)
"""
sco(s)
```

Time to get the letter counts and frequencies.

```jl
s = """
function getCounts(s::Str)::Dict{Char,Int}
    counts::Dict{Char, Int} = Dict()
    for char in s
        if haskey(counts, char)
            counts[char] = counts[char] + 1
        else
            counts[char] = 1
        end
    end
    return counts
end

function getFreqs(counts::Dict{Char, Int})::Dict{Char, Flt}
    total::Int = sum(values(counts))
    return Dict(k => v/total for (k, v) in counts)
end

function getFreqs(s::Str)::Dict{Char, Flt}
    return s |> getCounts |> getFreqs
end
"""
sc(s)
```

The code is rather simple. Moreover it is quite similar to `getCounts` and
`getProbs` that I discussed it in detail [in my previous
book](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_prob_theor_practice.html)
so give it a sneak peak if you need a more thorough explanation (I apply the DRY
principle here).

According to [this Wikipedia's
page](https://en.wikipedia.org/wiki/Letter_frequency) the letter that occurs
most often in English is `E` (frequency: 0.127 or 12.7%, compare with [this
discussion](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_probability_definition.html)).
Time to see which letter is the most frequent in our encoded text.

```jl
s = """
codedLetFreqs = getFreqs(codedTxt)
[k => v for (k, v) in codedLetFreqs if v > 0.12]
"""
sco(s)
```

And the winner is `R`. Interestingly, in the metal insides of a computer letters
are represented as numbers (see @sec:binary_problem and
[ASCII](https://en.wikipedia.org/wiki/ASCII)). We can use this to our advantage
and quickly obtain the shift.

```jl
s = """
'R' - 'E' # ASCII: 82 - 69
"""
sco(s)
```

And so it turns out, that our encrypted message was coded using a shift cipher
with the rotation of 13 (we will verify this finding in @sec:caesar). If we were
even more stubborn, we could display both the frequencies on a graph like
@fig:letterFrequency (we do not expect the fit to be perfect).

![Frequency analysis of an encrypted text.](./images/letterFreqency.png){#fig:letterFrequency}
