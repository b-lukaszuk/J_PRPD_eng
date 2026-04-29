# Bat and Ball {#sec:bat_and_ball}

In this chapter I used the following libraries.

```jl
s2 = """
import Symbolics as Sym # external library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/bat_and_ball)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:bat_and_ball_problem}

Recently, someone told me an interesting small mathematical problem that I
happened to knew from my youth:

> A bat and a ball cost in total $1.1. The bat costs $1 more than the ball. How
> much costs the ball?

Pause for a moment and try to find the answer. If you are stuck, then do this
with pen and paper first. Then watch
[this](https://www.youtube.com/watch?v=AUqeb9Z3y3k) video and look for Julia's
built in functionality that will speed up the longhand calculations.

## Solution {#sec:bat_and_ball_solution}

My first impulse was that the ball should cost $0.1 or 10 cents. It's the only
logical solution, right?

Surprisingly, it turns out that this simple problem trips up a lot of people (if
you were not one of them, congrats!).

Let's summon primary school math to the rescue and settle this once
and for all. From the task description we know that:

$$ bat + ball = 1.1 $$ {#eq:batball1}

$$ bat - ball = 1 $$ {#eq:batball2}

Therefore, we can rewrite the @eq:batball2 (move `- ball` to the
other side and change mathematical operation to the opposite) to get:

$$ bat = 1 + ball $$ {#eq:batball3}

Finally, by substituting `bat` from @eq:batball1 with `bat` from @eq:batball3
(`bat = 1 + ball`) we get.

$$ 1 + ball + ball = 1.1 $$

which we can simplify to

$$ 1 + 2*ball = 1.1 $$

$$ 2*ball + 1 = 1.1 $$

$$ 2*ball = 1.1 - 1 $$

$$ 2*ball = 0.1 $$

$$ ball = 0.1 / 2 $$

to finally get:

$$ ball = 0.05 $$

So it turns out that, counter-intuitively, the ball costs \$0.05 or 5 cents.

That's all very interesting, but what any of this got to do with Julia? Well,
just that we can solve this and more complicated equations with our favorite
programming language. For that purpose we will use matrices and their
multiplications as explained in
[this](https://www.youtube.com/watch?v=AUqeb9Z3y3k) Khan Academy's video.

```jl
s = """
variables = [
	1 1; # 1 bat + 1 ball
	1 -1 # 1 bat - 1 ball
]
"""
sco(s)
```

First we set the `variables` matrix where row 1 represents the left side of
@eq:batball1 and row 2 stands for the left side of @eq:batball2. Column 1
contains the number of `bat`s in each equation, whereas column 2 the number of
`ball`s.

And now for the right sides of the equations, we will place them in the `prices`
vector.

```jl
s = """
prices = [1.1, 1.0]
"""
sco(s)
```

All that's left to do, is to multiply the inverse (`inv`) of the matrix
`variables` by the `prices`.

```jl
s = """
result = inv(variables) * prices
# or, shortcut
result = variables \\ prices
round.(result, digits=4)
"""
sco(s)
```

Here we see the prices of `bat` (1.05) and `ball` (0.05) calculated by Julia.
We rounded the results to counterbalance inexact float representation in
computers (as discussed
[previously](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_variables.html#sec:julia_float_comparisons)).

Now, if you're new to matrix algebra, then this may look like an unnecessary
hassle and some obscure alchemy. In that case you may consider using
[Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl), a package with a
bit friendlier and more human readable syntax.

```jl
s = """
import Symbolics as Sym

Sym.@variables bat ball
result = Sym.symbolic_linear_solve(
	[
		bat + ball ~ 1.1,
		bat - ball ~ 1
	],
	[bat, ball]
);
map(x -> round(x.val, digits=4), result)
"""
sco(s)
```

First, we declare variables (`Sym.@variables`) that we will use in our equations
(customarily those are `x`, `y`, `z`, etc.), here we opted for more human
readable `bat` and `ball` names. Next we use `symbolic_linear_solve` function to
get the solution (the calculation process may take a second or two). It takes 2
arguments (separated by coma): 1) equation(s) and 2) variable(s) for which we
want to solve our equation. Since we got a set of 2 equations we place them in
square brackets separated by comma. Inside the equations we use previously
defined (`Sym.@variables`) variables (`bat` and `ball`) and `~` instead of `=`
known from mathematics. Next, we send the variable(s) we are looking for (`[bat,
ball]`). The number of variables should be equal to the number of equations in
the first argument, and if it is greater than 1 then we place them between
square braces and separate them with comas. And that's it.

Pretty neat trick. Worth to know if your math is rusty (like mine) and you want
to confirm your pen and paper calculations.
