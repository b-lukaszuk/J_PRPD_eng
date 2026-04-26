# Format Text {#sec:format_text}

In this chapter I used the following libraries.

```jl
s2 = """
import Random as Rnd # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/format_text)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:format_text_problem}

[Word processing
programs](https://en.wikipedia.org/wiki/List_of_word_processor_programs) offer
many text editing functionalities. In a pre-digital era, those tasks had to be
done manually. Anyway, let's try to do some typesetting with Julia.

Choose an exemplary text, like `text2beFormatted.txt` from [the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/format_text)
or [Lorem ipsum from this Wikipedia's
page](https://en.wikipedia.org/wiki/Lorem_ipsum). Next, write a program (a
series of functions) that will allow you to:

1. Left align,

```
------------------------------------------------------------------
|  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  |
|  do eiusmod tempor incididunt ut labore et dolore magna        |
|  aliqua. Ut enim ad minim veniam, quis nostrud exercitation    |
|  ullamco laboris nisi ut aliquip ex ea commodo consequat.      |
|  Duis aute irure dolor in reprehenderit in voluptate velit     |
|  esse cillum dolore eu fugiat nulla pariatur. Excepteur sint   |
|  occaecat cupidatat non proident, sunt in culpa qui officia    |
|  deserunt mollit anim id est laborum.                          |
------------------------------------------------------------------ 
```

2. Right align,

```
------------------------------------------------------------------
|  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  |
|        do eiusmod tempor incididunt ut labore et dolore magna  |
|    aliqua. Ut enim ad minim veniam, quis nostrud exercitation  |
|      ullamco laboris nisi ut aliquip ex ea commodo consequat.  |
|     Duis aute irure dolor in reprehenderit in voluptate velit  |
|   esse cillum dolore eu fugiat nulla pariatur. Excepteur sint  |
|    occaecat cupidatat non proident, sunt in culpa qui officia  |
|                          deserunt mollit anim id est laborum.  |
------------------------------------------------------------------ 
```

3. Center,

```
------------------------------------------------------------------
|  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  |
|     do eiusmod tempor incididunt ut labore et dolore magna     |
|   aliqua. Ut enim ad minim veniam, quis nostrud exercitation   |
|    ullamco laboris nisi ut aliquip ex ea commodo consequat.    |
|   Duis aute irure dolor in reprehenderit in voluptate velit    |
|  esse cillum dolore eu fugiat nulla pariatur. Excepteur sint   |
|   occaecat cupidatat non proident, sunt in culpa qui officia   |
|              deserunt mollit anim id est laborum.              |
------------------------------------------------------------------ 
```

4. Justify,

```
------------------------------------------------------------------
|  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  |
|  do eiusmod  tempor  incididunt  ut labore  et  dolore  magna  |
|  aliqua. Ut  enim ad minim  veniam, quis nostrud exercitation  |
|  ullamco  laboris nisi  ut  aliquip ex ea  commodo consequat.  |
|  Duis aute irure  dolor  in  reprehenderit in voluptate velit  |
|  esse cillum dolore eu fugiat nulla pariatur. Excepteur  sint  |
|  occaecat cupidatat  non proident, sunt in culpa  qui officia  |
|  deserunt mollit anim id est laborum.                          |
------------------------------------------------------------------ 
```

5. Justify in a double column layout

```
------------------------------------------------------------------
|  Lorem ipsum dolor sit  amet,    aute    irure    dolor    in  |
|  consectetur adipiscing elit,    reprehenderit  in  voluptate  |
|  sed   do    eiusmod   tempor    velit esse  cillum dolore eu  |
|  incididunt  ut   labore   et    fugiat    nulla    pariatur.  |
|  dolore magna aliqua. Ut enim    Excepteur   sint    occaecat  |
|  ad    minim   veniam,   quis    cupidatat non proident, sunt  |
|  nostrud exercitation ullamco    in    culpa    qui   officia  |
|  laboris  nisi  ut aliquip ex    deserunt  mollit anim id est  |
|  ea  commodo consequat.  Duis    laborum.                      |
------------------------------------------------------------------ 
```

the text (the borders are optional).

For simplicity, you may assume the text to be composed of [ASCII encoded
symbols](https://en.wikipedia.org/wiki/ASCII) with the words composed of, let's
say, up to 10-15 letters and separated by an unspecified number of [whitespace
characters](https://en.wikipedia.org/wiki/Whitespace_character). Feel free to
adjust the task to your programming experience and do as many tasks as you deem
suitable.

## Solution {#sec:format_text_solution}

Before we begin, let's define a few
[const](https://docs.julialang.org/en/v1/base/base/#const)ants that will be used
throughout the program.

```
const PAD = " "
const COL_SEP = PAD ^ 4
const MAX_LINE_LEN = 60
```

Next, our first step in formatting a paragraph will be to break it into lines,
each with the length smaller than or equal to some target value.

```
function getLines(txt::Str, targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    @assert 19 < targetLineLen < 61 "targetLineLen must be in range [20-60]"
    words::Vec{Str} = split(txt)
    lines::Vec{Str} = []
    curLine::Str = ""
    difference::Int = 0
    for word in words
        difference = targetLineLen - length(curLine) - length(word)
        if difference >= 0
            curLine *= word * PAD
        else
            push!(lines, strip(curLine))
            curLine = word * PAD
        end
    end
    push!(lines, strip(curLine))
    return lines
end
```

For that we break our text (`txt`) into `words` with the
[split](https://docs.julialang.org/en/v1/base/strings/#Base.split)
function. Then, `for` each `word` we calculate the `difference` between our
desired line length (`targetLineLen`) and the current line length
(`length(curLine)`) plus the length of the word (`length(word)`) we want to add
to that line. If we still got room for one more word (`if difference >= 0`) then
we just add it with a padding on the right side (`curLine *= word *
PAD`). Otherwise (`else`), we add `curLine` to the vector of `lines` with
`push!` and make our `word` the beginning of a new line (`curLine = word *
PAD`). Notice, that before `push`ing the old line to the collection, first, we
`strip`ped it from any possible extra spaces on the edges. Afterwards (`end` of
`for`), we `push` the last line to `lines` and return the latter from inside the
function.

Now, for left-, right- and center alignment, each line will have to be padded
with space characters (`PAD`) placed on the right, left, and both sides,
respectively. For that we need to know the difference between the number of
characters in our line and its target length. Moreover, we need a padding
function that we will name creatively as `padLine`. Here, we went with the `*`
operator that glues two strings together and the `^` symbol that repeats the
string on its left the number of times on its right (remember about the operator
precedence from mathematics). Alternatively, we could have used the built in
[\@sprintf](https://docs.julialang.org/en/v1/stdlib/Printf/#Printf.@sprintf)
(e.g. `@sprintf("%60s", "xxx")`/`@sprintf("%-60s", "xxx")` to get the `"xxx"`
right/left justified for
us). [Lpad](https://docs.julialang.org/en/v1/base/strings/#Base.lpad) and
[rpad](https://docs.julialang.org/en/v1/base/strings/#Base.rpad) were also a
viable option.

```
function getLenDiffs(lines::Vec{Str},
                     targetLineLen::Int=MAX_LINE_LEN)::Vec{Int}
    return targetLineLen .- map(length, lines)
end

function padLine(line::Str, lPadLen::Int, rPadLen::Int,
                 lPad::Str=PAD, rPad::Str=PAD)::Str
    @assert lPadLen >= 0 && rPadLen >= 0 "padding lengths must be >= 0"
    return lPad ^ lPadLen * line * rPad ^ rPadLen
end
```

Once we got it, padding lines should be a breeze.

```
function getPaddedLines(lines::Vec{Str},
                         lPadsLens::Vec{Int}, rPadsLens::Vec{Int})::Vec{Str}
    @assert(length(lines) == length(lPadsLens) == length(rPadsLens),
            "all vectors must be of equal lengths")
    return map(padLine, lines, lPadsLens, rPadsLens)
end
```

Here, similarly to @sec:mat_multip_solution, we use
[map](https://docs.julialang.org/en/v1/base/collections/#Base.map), which
applies a function (`padLine`) to every consecutive elements of `lines`,
`lPadsLens` and `rPadsLens` in turn. So it goes like: `padLine(lines[1],
lPadsLens[1], rPadsLens[1])` and `padLine(lines[2], lPadsLens[2],
rPadsLens[2])`, etc., and collects the results into a vector.

Now, the formatting reduces down to obtaining the lines, and calculating the
diffs, which we do on the fly with this code snippet (`div(x, y)` divides `x` by
`y` and returns an integer by dropping fractional part when necessary).

```
function getLeftAlignedLines(txt::Str,
                             targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    lines::Vec{Str} = getLines(txt, targetLineLen)
    rPadsLens::Vec{Int} = getLenDiffs(lines, targetLineLen)
    return getPaddedLines(lines, zeros(Int, length(lines)), rPadsLens)
end

function getRightAlignedLines(txt::Str,
                              targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    lines::Vec{Str} = getLines(txt, targetLineLen)
    lPadsLens::Vec{Int} = getLenDiffs(lines, targetLineLen)
    return getPaddedLines(lines, lPadsLens, zeros(Int, length(lines)))
end

function getCenteredLines(txt::Str,
                          targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    lines::Vec{Str} = getLines(txt, targetLineLen)
    diffs::Vec{Int} = getLenDiffs(lines, targetLineLen)
    lPadLens::Vec{Int} = div.(diffs, 2)
    rPadLens::Vec{Int} = diffs .- lPadLens
    return getPaddedLines(lines, lPadLens, rPadLens)
end

function printLines(lines::Vec{Str})::Nothing
    join(lines, "\n") |> print
    return nothing
end
```

Go ahead, test it out (e.g. `getCenteredLines(lorem) |> printLines`) and see how
it works.

OK, time for a function that will justify our line (`justifyLine`). Here, our
approach will be slightly different. First, we'll break the line into words
(with `split`). Then, we'll figure out how many regular (`nSpacesBtwnWords`)
spaces and extra spaces (`nExtraSpaces`) between the words we need. Finally,
we'll place the extra spaces in random places (with `getSample`) between the
words (with `intercalate`).

```
# draws n random elements from v (without replacement)
function getSample(v::Vec{A}, n::Int)::Vec{A} where A
    @assert 0 <= n <= length(v) "n must be in range [0-length(v)]"
    return Rnd.shuffle(v)[1:n]
end

function intercalate(v1::Vec{Str}, v2::Vec{Str})::Str
    @assert(length(v1) == (length(v2)+1),
            "length(v1) must be equal length(v2)+1")
    return join(map(*, v1, v2)) * v1[end]
end

function justifyLine(line::Str, lastLine::Bool=false,
                     targetLineLen::Int=MAX_LINE_LEN)::Str
    words::Vec{Str} = split(line)
    if  length(words) < 2 || lastLine
        return padLine(line, 0, targetLineLen - length(line))
    end
    nSpacesBtwnWords::Int = length(words) - 1
    nSpacesTotal::Int = targetLineLen - sum(map(length, words))
    spaceBtwnWordsLen::Int = div(nSpacesTotal, nSpacesBtwnWords)
    nExtraSpaces::Int = nSpacesTotal - nSpacesBtwnWords * spaceBtwnWordsLen
    spaces::Vec{Str} = fill(PAD ^ spaceBtwnWordsLen, nSpacesBtwnWords)
    inds::Vec{Int} = getSample(collect(eachindex(spaces)), nExtraSpaces)
    spaces[inds] .*= PAD
    return intercalate(words, spaces)
end
```

Let's briefly discuss some of the more interesting parts of the code snippet. We
start by determining how many spaces between the words there are
(`nSpacesBtwnWords`) and how many spaces in total we need in order to reach our
`targetLineLen` (`nSpacesTotal`). In the perfect world, `nSpacesTotal` should
divide by `nSpacesBtwnWords` evenly (`spaceBtwnWordsLen` should be an
integer). To help that happen we use `div` (it drops the fractional
part). Moreover, we also account for the possible extra spaces needed
(`nExtraSpaces`, when the dropped fractional part was greater than 0). Once we
got it, we get a vector of regular spaces between the words and place it in
`spaces`. Then, we draw random indices (`inds`) from `spaces` to which we will
add a single extra space (`PAD`). Notice that `spaces[inds] .= PAD` would
replace every element of `spaces` (indicated by `inds`) with `PAD`. Instead,
`spaces[inds] .*= PAD` will take every element and update it (`*=`) with `PAD`,
which in this case means just appending (`*`) `PAD` (a string) to the string
that was previously in an element of `spaces`. Finally, we intercalate `words`
in a `line` with `spaces` (regular and extra), which we `return`. And voila, all
that's left to do is to justify every line

```
function getJustifiedLines(txt::Str,
                           targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    lines::Vec{Str} = getLines(txt, targetLineLen)
    return map(line -> justifyLine(
        line, line == lines[end], targetLineLen), lines)
end
```

and test it out (`getJustifiedLines(lorem) |> printLines`).

As for the double column justified layout, it's pretty straightforward. We'll
get a single justified column (that is roughly half the width of
`MAX_LINE_LEN`), split it approximately in half and glue together lines from
adjacent columns. Let's get into it.

```
function connectColumns(col1lines::Vec{Str}, col2lines::Vec{Str})::Vec{Str}
    @assert(length(col1lines) >= length(col2lines),
            "col1lines must have >= elements than col2lines")
    result::Vec{Str} = fill("", length(col1lines))
    emptyColPad = padLine("", 0, length(col1lines[1]))
    for i in eachindex(col1lines)
        result[i] = string(col1lines[i], COL_SEP,
                           get(col2lines, i, emptyColPad))
    end
    return result
end

function getDoubleColumn(txt::Str,
                         targetLineLen::Int=MAX_LINE_LEN)::Vec{Str}
    @assert 19 < targetLineLen < 61 "targetLineLen must be in range [20-60]"
    lines::Vec{Str} = getJustifiedLines(
        txt, div(targetLineLen, 2) - div(length(COL_SEP), 2), ) # 2 - nCols
    midPoint::Int = ceil(Int, length(lines)/2)
    return connectColumns(lines[1:midPoint], lines[(midPoint+1):end])
end
```

Of note, `connectColumns` walks through every index in `col1lines`
(`eachindex(col1lines)`) and glues together the columns with the `string`
function. The outcome of such string concatenation is put into
`result[i]`. Splitting a long thin column in half may result in a columns of a
slightly different lengths. Therefore, we cannot just use a regular indexing on
`col2lines` (because if the element is not there we'll get an error). Instead,
we use the `get` function that we [encountered while working with
dictionaries](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_decision_making.html#sec:julia_language_dictionaries).
Likewise, here we also use a default value (`emptyColPad`) that gets returned if
an element at a given index does not exist. It seems that we're done with the
chapter's task. Go ahead, test the last function (`getDoubleColumn(lorem) |>
printLines `).

For a final challenge (a cherry on the top) add borders to the printout (or use
the function `addBorder` from [the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/format_text)). This
will allow to better visualize the correctness of your padding.
