# Matrix Multiplication {#sec:mat_multip}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/matrix_multiplication)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:mat_multip_problem}

In Julia a
[matrix](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_variables.html#sec:julia_arrays)
is a tabular representation of two-dimensional (rows and columns) data. We
declare it with a friendly syntax (columns separated by spaces, rows separated
by semicolons).

```jl
s = """
A = [10.5 9.5; 8.5 7.5; 6.5 5.5]
A
"""
sco(s)
```

In mathematics by convention we denote matrices with a single capital
letter. However, since I'm not a mathematician then I'll use the lowercase names
(they are easier for the fingers).

I remember that the first time that I was introduced to the matrix algebra I
found it pretty boring and burdensome. However, believe it or not, matrices are
very useful in mathematics and in everyday life, e.g statistical programs or
programs rendering computer graphics rely on them heavily (chances are you used
them without even being aware of it).

Anyway, here is the task. Read about matrix multiplication, e.g. on [Math is
Fun](https://www.mathsisfun.com/algebra/matrix-multiplying.html) or watch a
[Khan Academy's video](https://www.youtube.com/watch?v=OMA2Mwo0aZg) on the topic
and write a function with the following signature

```
multiply(m1::Matrix{Int}, m2::Matrix{Int})::Int
```

that for

```jl
s = """
# Math is Fun example
a = [1 2 3; 4 5 6]
"""
sco(s)
```

and

```jl
s = """
# Math is Fun example
b = [7 8; 9 10; 11 12]
"""
sco(s)
```

Should return the following matrix

```jl
s = """
[58 64; 139 154]
"""
sco(s)
```

Compare `multiply` against Julia's built-in `*` operator (on some matrices of
your choice) to ensure its correct functioning.

## Solution {#sec:mat_multip_solution}

It appears that in order to multiply two matrices we need to multiply each
element in a row from a matrix by each element in a column of another
matrix. Once we are done we sum the products. This is called a dot product. So,
let's start with that.

```jl
s = """
function getDotProduct(row::Vec{Int}, col::Vec{Int})
    @assert length(row) == length(col) "row & col must be of equal length"
    return map(*, row, col) |> sum
end
"""
sc(s)
```

> Note. Thanks to the previously defined (@sec:about) type synonyms we saved
> some typing and used `Vec{Int}` instead of `Vector{Int}`. We will use such
> small convenience(s) throughout the book. The type synonyms are defined in
> @sec:about and/or in the code snippets for each chapter.

First, we place a simple assumption check with the
[assert](https://docs.julialang.org/en/v1/base/base/#Base.@assert). Then we
multiply each element of `row` by each element of `col` with `map`. `Map`
applies a function (its first argument) to every element of a collection (its
second argument), like so:

```jl
s = """
# adds 10 to each element of a vector
map(x -> x + 10, [1, 2, 3])
"""
sco(s)
```

Here we used a vector (`[1, 2, 3]`) and applied an anonymous function
(`x -> x + 10`) to each of its elements. The function accepts one argument
(`x`), adds 10 to it (`x + 10`) and returns (`->`) that value. Since `x` will
become every element of the vector `[1, 2, 3]` then in effect 10 will be added
to the each component of the vector and the results will be collected into a new
vector (the old vector is not changed). Interestingly, we may also use a
function that accepts two arguments and apply this function to parallel elements
of two vectors, like so:

```jl
s = """
map((x, y) -> x * y, [1, 2, 3], [10, 100, 1000])
"""
sco(s)
```

Here, `x` becomes every value of `[1, 2, 3]` and `y` every value of
`[10, 100, 1000]` vector. Given that `*` is just a syntactic sugar for `*(x, y)`
we may simply place `*` alone.

```jl
s = """
map(*, [1, 2, 3], [10, 100, 1000])
"""
sco(s)
```

Since we calculate a dot product, then as an alternative (to live up to its
name) we could also use the [dot
operator](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_repetition.html#sec:julia_language_dot_functions)
syntax in our `getDotProduct` function like so:

```jl
s = """
[1, 2, 3] .* [10, 100, 1000]
"""
sco(s)
```

Anyway, once we got the vector of products we send it
([|>](https://docs.julialang.org/en/v1/base/base/#Base.:%7C%3E)) as an input to
`sum`.

OK, time for the multiplication itself.

```jl
s = """
function multiply(m1::Matrix{Int}, m2::Matrix{Int})::Matrix{Int}
    nRowsMat1, nColsMat1 = size(m1)
    nRowsMat2, nColsMat2 = size(m2)
    @assert  nColsMat1 == nRowsMat2 "the matrices are incompatible"
    result::Matrix{Int} = zeros(nRowsMat1, nColsMat2)
    for r in 1:nRowsMat1
        for c in 1:nColsMat2
            result[r, c] = getDotProduct(m1[r,:], m2[:, c])
        end
    end
    return result
end
"""
sc(s)
```

The above is a translation of the algorithm from the links provided in the task
description (see @sec:mat_multip_problem). First we get our matrices dimensions
and perform a compatibility check with `@assert`. Then we initialize an empty
matrix (`result`) with the appropriate dimensions (we use `zeros`, so 0s are the
placeholders stored in its cells). Finally, we get the dot products of every row
(`for r`) in `m1` by every column (`for c`) in `m2` and place them to the
appropriate cells in the `result` matrix.

Alternatively, if you are not a fan of nesting, you may use Julia's simplified
nested for loop syntax. It works the same as the previous code snippet.

```jl
s1 = """
function multiply(m1::Matrix{Int}, m2::Matrix{Int})::Matrix{Int}
    nRowsMat1, nColsMat1 = size(m1)
    nRowsMat2, nColsMat2 = size(m2)
    @assert  nColsMat1 == nRowsMat2 "the matrices are incompatible"
    result::Matrix{Int} = zeros(nRowsMat1, nColsMat2)
    for r in 1:nRowsMat1, c in 1:nColsMat2
        result[r, c] = getDotProduct(m1[r,:], m2[:, c])
    end
    return result
end
"""
sc(s1)
```

Anyway, let's give it a swing.

```jl
s = """
# Math is Fun examples
a = [1 2 3; 4 5 6]
b = [7 8; 9 10; 11 12]
multiply(a, b)
"""
sco(s)
```

Looks good, and

```jl
s = """
# Khan Academy examples
c = [-1 3 5; 5 5 2]
d = [3 4; 3 -2; 4 -2]
multiply(c, d)
"""
sco(s)
```

Appears to be correct as well.

And now for a few tests against the build in `*` operator.

```jl
s = """
(a * b) == multiply(a, b)
(c * d) == multiply(c, d)
"""
sco(s)
```

We can't complain. Of course, our `multiply` works only for matrices of `Int`s.
If you find that a problem, you may extend it by replacing `Int` with `<:Real`
(sub-type of [Real](https://docs.julialang.org/en/v1/base/numbers/#Core.Real))
or `<:Number` (sub-type of
[Number](https://docs.julialang.org/en/v1/base/numbers/#Core.Number)) or even
by removing the type declarations altogether. But then again, it was just a
programming exercise and for a real work we will rely on the built in
functionality.

Anyway, it appears that we managed to solve this task in like 15 lines of code
and without over-engineering it too much. It's all thanks to the Julia's nice
and terse syntax.
