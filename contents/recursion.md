# Recursion {#sec:recursion}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/recursion)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:recursion_problem}

[Recursion](https://en.wikipedia.org/wiki/Recursion_(computer_science)) is a
programming technique where a function invokes itself in order to solve a
problem. It relies on two simple principles:

1. know when to stop
2. split the problem into a single step and a smaller problem

And that's it. Let's see how this works in practice.

For that we'll write a recursive function that sums the elements of a vector of
integers.

```jl
s = """
function recSum(v::Vec{Int})::Int
    if isempty(v)
        return 0
    else
        return v[1] + recSum(v[2:end])
    end
end
"""
sc(s)
```

We begin by defining our edge case (know when to stop). If the vector (`v`) is
empty (`if isempty(v)`) we return 0 (BTW. Notice that zero is a neutral
mathematical operation for addition, any number plus zero is just itself).
Otherwise (`else`) we add the first element of the vector (`v[1]`, single step)
to whatever number is returned by `recSum` with the rest of the vector
(`v[2:end]`) as an argument (smaller problem).

Time for a couple of examples.

For

```jl
s = """
recSum([1])
"""
sco(s)
```

the execution of the program looks something like

```
recSum([1]) # triggers else branch
	1 + recSum([]) # triggers if branch (stop)
		1 + 0 # stop reached, time to return
1
```

Whereas for

```jl
s = """
recSum([1, 2, 3])
"""
sco(s)
```

we get

```
recSum([1, 2, 3]) # triggers else branch
	1 + recSum([2, 3]) # triggers else branch
		1 + 2 + recSum([3]) # triggers else branch
			1 + 2 + 3 + recSum([]) # triggers if branch (stop)
				1 + 2 + 3 + 0 # stop reached, time to return
6
```

It is difficult to imagine step by step, but `recSum` works equally well for a
bit broader range of numbers.

```jl
s = """
1:100 |> collect |> recSum
"""
sco(s)
```

Believe it or not, but that last one you can calculate fairly easily yourself if
you apply [the Gauss
method](https://www.nctm.org/Publications/TCM-blog/Blog/The-Story-of-Gauss/).

Anyway, usually recursion is not very effective and it can be rewritten with
loops. Moreover, too big input, e.g. `1:100_000`, will likely cause an error
with `recSum`, but not with the built-in `sum`. Still, for some problems
recursion is an easy to implement and elegant solution that gets the job
done. Therefore, it is worth to have this technique in your programming toolbox.

Classical examples of recursive process in action are the
[factorial](https://en.wikipedia.org/wiki/Factorial) and the [Fibonacci
sequence](https://en.wikipedia.org/wiki/Fibonacci_sequence) which are your tasks
for this section.

## Solution {#sec:recursion_solution}

A factorial is an interesting little function with a set of practical
applications, one of them I explained
[here](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_exercises.html#sec:statistics_intro_exercise2).

Its recursive implementation follows closely the mathematical definition (see
below, where `n!` is a factorial of a number `n`).

$$
\begin{align*}
n! = \left\{
    \begin {aligned}
         & 1 \quad & \text{if } n = 1 \\
         & n \times (n-1)! \quad & \text{otherwise}
    \end{aligned}
\right.
\end{align*}
$$

Which can be translated into Julia's:

```jl
s = """
function recFactorial(n::Int)::Int
    @assert 1 <= n <= 20 "n must be in range [1-20]"
    if n == 1
        return 1
    else
        return n * recFactorial(n-1)
    end
end
"""
sc(s)
```

In general, a factorial is well defined for positive integers and it grows very
quickly (n > 20 would produce
[overflow](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Overflow-behavior),
to resolve it we could use `BigInt` instead of `Int`) hence the `@assert` line.
Anyway, for `n` equal 1 we return 1 (our base case), otherwise we multiply `n`
by `recFactorial(n-1)`. Go ahead, follow the execution of the program for small
inputs like `recFactorial(3)` in your head (similarly to `recSum` from
@sec:recursion_problem).

To get you a better feel for recursion in Julia, here are two other equivalent
implementations of `recFactorial`.

```jl
s = """
function recFactorialV2(n::Int)::Int
    @assert 1 <= n <= 20 "n must be in range [1-20]"
    return n == 1 ? 1 : n * recFactorialV2(n-1)
end
"""
sc(s)
```
and

```jl
s = """
function recFactorialV3(n::Int, acc::Int=1)::Int
    @assert 1 <= n <= 20 "n must be in range [1-20]"
    return n == 1 ? acc : recFactorialV3(n-1, n * acc)
end
"""
sc(s)
```

The second version (`recFactorialV2`) uses [ternary
operator](https://docs.julialang.org/en/v1/base/base/#?:) instead of more
verbose `if else` statements. The third version (`recFactorialV3`) relies on a
so called accumulator (`acc`) that stores the result of a previous calculation
(if any). `recFactorialV3` is a tail-recursive function that is recommended in
some programming languages, like
[Haskell](https://en.wikipedia.org/wiki/Haskell) and
[Scala](https://en.wikipedia.org/wiki/Scala_(programming_language)), that can
take advantage of this kind of code to produce (internally) an effective
function implementation.

Let's go to the Fibonacci sequence. When I was a student, they said that dinners
in the student's canteen are like Figonacci numbers, i.e. each dinner is the sum
of the two previous ones. To put it more mathematically, we get

$$
\begin{align*}
fib(n) = \left\{
	\begin {aligned}
         & 0 \quad & \text{if } n = 0 \\
         & 1 \quad & \text{if } n = 1 \\
         & fib(n-2) + fib(n-1) \quad & \text{otherwise}
    \end{aligned}
\right.
\end{align*}
$$

Which expressed in Julia gives us:

```jl
s = """
function recFib(n::Int)::Int
    @assert 0 <= n <= 40 "n must be in range [0-40]"
    if n == 0
        return 0
    elseif n == 1
        return 1
    else
        return recFib(n - 2) + recFib(n - 1)
    end
end

recFib(10)
"""
sco(s)
```

The numbers do not grow as fast as `factorial`s, but the algorithm, although
simple, is very inefficient. For instance, for `recFib(3)` I have to calculate
`recFib(1) + recFib(2)`, but `recFib(2)` will calculate `recFib(1)` inside of it
as well. For greater numbers (inputs) the duplicated operations threaten to
throttle the processor. On my laptop the computation for `recFib(40)` takes
roughly 600-700 [ms], so more than half a second, a delay noticed even by a
human.

Therefore we may improve our last function by using lookup tables/dictionaries
like so:

```jl
s = """
function recFib!(n::Int, lookup::Dict{Int, Int})::Int
    @assert 0 <= n <= 40 "n must be in range [0-40]"
    @assert(haskey(lookup, 0) && haskey(lookup, 1),
		"lookup must have base cases")
    if !haskey(lookup, n)
        lookup[n] = recFib!(n-2, lookup) + recFib!(n-1, lookup)
    end
    return lookup[n]
end
"""
sc(s)
```

Notice that the function modifies `lookup` (hence `!` appended to its name, per
Julia's convention). Inside we check if there is a value for a Fibonacci's
number in `lookup`. If not (`!haskey(lookup, n)`) then we calculate it using the
known formula and insert it in `lookup`. Otherwise we just return the found
value.

The last function (`recFib!`) is more performant, as:

```jl
s = """
fibs = Dict(0 => 0, 1 => 1)
recFib!(40, fibs)
"""
sco(s)
```

takes only microseconds on its first execution (hundreds to thousand times
faster). Interestingly, running `recFib!(40, fibs)` for the second time reduces
the time to nanoseconds (million(s) times faster) since there are no
calculations performed the second time, just reading the number from the
previously modified `lookup`). Run `recFib(40)` twice to convince yourself that
it takes roughly the same amount of time every time it runs with the same `n`.
