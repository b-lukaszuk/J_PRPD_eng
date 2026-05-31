# Pascal's Triangle {#sec:pascals_triangle}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/pascals_triangle)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:pascals_triangle_problem}

Imagine that you are a basketball coach in a local school. A basketball team is
composed of 5 players. Nine kids attend your classes. You would like the kids to
play in every possible configuration so that you could choose the best team to
represent the school next month. You wonder how many different teams of 5
players can you compose out of 9 candidates.

Such a question could be answered with the
[binomial](https://docs.julialang.org/en/v1/base/math/#Base.binomial) function
or [Pascal's triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle).

So here is a task for you, write a program that will display the Pascal's
triangle that will help you to answer the question mentioned above.

Compare its output with `binomial`.

The function can display a bare (right) triangle

```
[1]
[1, 1]
[1, 2, 1]
[1, 3, 3, 1]
```

or if you like challenges a slightly formatted output (it doesn't have to be
exact):

```
   1
  1 1
 1 2 1
1 3 3 1
    ∆
```

The above indicates how many pairs of people can we get out of 3 candidates
(e.g. in order to play doubles in tennis).

## Solution {#sec:pascals_triangle_solution}

If you read [the Wikipedia's description of the Pascal's
triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle) then you may have
noticed this cool animation (see below).

![Construction of a Pascal's triangle. Source:
[Wikipedia](https://en.wikipedia.org/wiki/File:PascalTriangleAnimated2.gif)
(public domain, used in accordance with the Licensing
section, animation works only in an HTML document).](./images/PascalTriangleAnimated2.gif){#fig:pascalsTriangle}

It indicates that in order to create a new row of the triangle you just take the
previous row and add pair of its elements together to create the next
row. Finally, at the edges of the new row you place 1s. So let's start by doing
just that.

```jl
s = """
function getSumOfPairs(prevRow::Vec{Int})::Vec{Int}
    @assert all(prevRow .> 0) "every element of prevRow must be > 0"
    return [a + b for (a, b) in zip(prevRow, prevRow[2:end])]
end

function getRow(prevRow::Vec{Int})::Vec{Int}
    @assert length(prevRow) > 1 "length(prevRow) must be > 1"
    sumsOfPairs::Vec{Int} = getSumOfPairs(prevRow)
    return [1, sumsOfPairs..., 1]
end
"""
sc(s)
```

The first function (`getSumOfPairs`) creates pairs of values based on the
previous row (`prevRow`). It returns a vector of tuples of `(a, b)` that are the
elements from the zipped vectors, e.g.

```jl
s = """
zip([1, 2, 3, 4], [2, 3, 4]) |> collect
"""
sco(s)
```

Notice, that the second argument to `zip` is almost the same as its first
argument (just like `prevRow[2:end]` in the body of `getSumOfPairs`) and the
parallel elements from both the vectors are `zip`ped together as long as there
are pairs. Next, the numbers in a pair are added (`a + b` in the body of
`getSumOfPairs`). Finally, `getRow` uses the `sumsOfPairs` and adds 1s on the
edges. The `...` in `getRow` unpacks elements from a vector, i.e. `[1, [3,
2]..., 1]` becomes `[1, 3, 2, 1]`. All in all, we got a pretty faithful
translation of the algorithm (from @fig:pascalsTriangle) to Julia.

Now we are ready to build the triangle row by row.

```jl
s = """
function getPascalTriangle(n::Int)::Vec{Vec{Int}}
    @assert 0 <= n <= 10 "n must be in range [0-10]"
    triangle::Dict{Int, Vec{Int}} = Dict(0 => [1], 1 => [1, 1])
    if !haskey(triangle, n)
        for row in 2:n
            triangle[row] = getRow(triangle[row-1])
        end
    end
    return [triangle[k] for k in 0:n]
end
"""
sc(s)
```

We define our triangle with initial two rows. Next, we move downwards through
the possible triangle rows (`for row in 2:n`) and build the next row based on
the previous one (`getRow(triangle[row-1])`). All that's left to do is to
`return` the triangle as a vector of vectors (`Vec{Vec{Int}})`) which will give
us a right triangle printed in the output by default. For instance, let's get
the Pascal's triangle from @fig:pascalsTriangle.

```jl
s = """
getPascalTriangle(4)
"""
sco(s)
```

Pretty neat, we could stop here or try to add some text formatting. In order to
do that we will need some way to determine the length of an integer when printed
(`getNumLen` below) as well as the maximum number length in a Pascal's triangle.
The latter can be done by examining its last (longest) row, hence `getMaxNumLen`
below accepts a vector.

```jl
s = """
function getNumLen(n::Int)::Int
    return n |> string |> length
end

function getMaxNumLen(v::Vec{Int})::Int
    return map(getNumLen, v) |> maximum
end
"""
sc(s)
```

Once we got it, we need a way to center a number or a row (represented as a
string).

```jl
s = """
function center(sth::A, endLength::Int)::Str where A<:Union{Int, Str}
    s::Str = string(sth)
    len::Int = length(s)
    @assert endLength > 0 && len > 0 "both endLength and len must be > 0"
    @assert endLength >= len "endLength must be >= len"
    diff::Int = endLength - len
    leftSpaceLen::Int = div(diff, 2) # divide by 2, round down
    rightSpaceLen::Int = diff - leftSpaceLen
    return " " ^ leftSpaceLen * s * " " ^ rightSpaceLen
end
"""
sc(s)
```

In order to center its input (`sth` - an integer or a string, as stated in
`A<:Union{Int, Str}`) the function determines the difference (`diff`) between
the length of the desired result (`endLength`) and the actual length of `s`
(`len`). The difference is split roughly in half (`leftSpaceLen` and
`rightSpaceLen`) and glued together with `s` using string concatenation (`*`)
and exponentiation (`^`) that we met in @sec:progress_bar_solution. Due to the
limited resolution offered by the text display of a terminal the result is
expected to be slightly off on printout, but I think we can live with that.

Time to format a row.

```jl
s = """
function getFmtRow(
	row::Vec{A}, numLen::Int, rowLen::Int)::Str where A<:Union{Int, Str}
    fmt(num) = center(num, numLen)
    formattedRow::Str = join(map(fmt, row), " ")
    return center(formattedRow, rowLen)
end
"""
sc(s)
```

For that we just `map` a formatter (`fmt`) over every element of the `row` and
`join` the resultant vector of strings intercalating its elements with space
(`" "`). Finally, we center the `formattedRow` to the desired length (`rowLen`).

All that's left to do is to get a formatted triangle.

```jl
s = """
function getFmtPascTriangle(n::Int, k::Int)::Str
    @assert n >= 0 && k >= 0 "n and k must be >= 0"
    @assert n <= 10 && k <= 10 "n and k must be <= 10"
    @assert n >= k "n must be >= k"
    triangle::Vec{Vec{Int}} = getPascalTriangle(n)
    lastRow::Vec{Int} = triangle[end]
    maxNumWidth::Int = getMaxNumLen(lastRow) + 1
    lastRowWidth::Int = (n+1) * maxNumWidth + n
    fmtRow(row) = getFmtRow(row, maxNumWidth, lastRowWidth)
    formattedTriangle::Str = join(map(fmtRow, triangle), "\\n")
    indicators::Vec{Str} = fill(" ", n+1)
    indicators[k+1] = "∆"
    return formattedTriangle * "\\n" * fmtRow(indicators)
end
"""
sc(s)
```

Since `getFmtPascTriangle` is a graphical equivalent of `binomial(n, k)` then
it's only fitting to accept the two letters (`n` and `k`) as its input. We begin
by obtaining the `triangle`, its `lastRow` and based on it the maximum width of
a number in the triangle (`maxNumWidth`, the magic number `+1` is to produce
more visually pleasing output). Next, we determine the width of the last
row. Notice the `n+1` part (here and below in the function) as well as `k+1`
part later on. In, general Julia and humans count elements starting from 1,
whereas a Pascal's triangle is 0 indexed, hence we added `+1` to help us
translate one system into the other. Anyway, the length of `lastRow` (the
longest row in `triangle`) is the number of digits in the row (`(n+1)`) times
the width of a formatted digit (`maxNumWidth`) plus the number of spaces between
the formatted digits. The number of spaces is 1 less than the number of slots,
e.g., humans got 5 fingers, and 4 spaces between them, hence here we used `+n`
since the number of digits was `(n+1)`. Next, we obtain the `formattedTriangle`
by `map`ing `fmtRow` on its each row and separating the rows with newlines
(`\n`). We finish, by adding the indicator (`"∆"`) under our `k` and voila, we
are finally ready to answer our question.

```
# how many different teams of 5 players
# can we compose out of 9 candidates?
getFmtPascTriangle(9, 5)
```

```
                        1
                      1    1
                    1    2    1
                 1    3    3    1
              1    4    6    4    1
            1    5   10   10    5    1
          1    6   15   20   15    6    1
       1    7   21   35   35   21    7    1
    1    8   28   56   70   56   28    8    1
  1    9   36   84  126  126   84   36    9    1
                           ∆
```

Wow, 126. Who would have thought. Just in case let's compare the output with the
built in `binomial` (compare with the last row of the triangle).

```jl
s = """
binomial.(9, 0:9)
"""
sco(s)
```

So, I guess our triangle works right. Actually the two edge cases are easy
enough for us to check them in our heads. For instance, how many different teams
of 0 players can we compose out of 9 candidates? Well, there is only one way to
do that (`1` in the bottom row, first from the left), by not choosing any player
at all. And how many different teams of 1 player can we compose of 9 candidates?
Well, nine teams (`9` in the bottom row, second from the left) because each
player would compose one separate team.
