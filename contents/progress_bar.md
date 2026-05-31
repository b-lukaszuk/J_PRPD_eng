# Progress Bar {#sec:progress_bar}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/progress_bar)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:progress_bar_problem}

While running a time consuming program we may see a progress bar that will
provide the user with visual cues as to the course of its execution.

So here is a task for you. Write a computer program that will animate a mock
progress bar that goes from 0% to 100% (if you want, make it similar to the one
in @fig:progressBar1). Don't worry about the complex calculations (the task is
just to animate the bar), use
[sleep](https://docs.julialang.org/en/v1/base/parallel/#Base.sleep) before
printing the bar in each iteration. In order to redraw a bar in a
[terminal](https://en.wikipedia.org/wiki/Terminal_emulator) you may want to read
about [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code). If
the above is too much for you try to use [carriage
return](https://en.wikipedia.org/wiki/Carriage_return),
i.e. `print(progress_bar1)`, `print("\r")` and `print(progress_bar2)`.

![A mock progress bar (animation works only in an HTML document)](./images/progressBar.gif){#fig:progressBar1}

## Solution {#sec:progress_bar_solution}

Let's begin with a function that will return a textual representation of a
progress bar.

```jl
s2 = """
function getProgressBar(perc::Int)::Str
    @assert 0 <= perc <= 100 "perc must be in range [0-100]"
    return "|" ^ perc * "." ^ (100-perc) * xxx
end
"""
replace(sc(s2), "xxx" => "\" \$perc%\"")
```

In order to understand the function we must remember the precedence of
mathematical operations [exponentiation (`^`) before multiplication
(`*`)]. Moreover, we must keep in mind that in the context of strings `*` is a
[concatenation](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation)
operator (it glues two strings into a one longer string), whereas `^` multiplies
a string to its left the number of times on its right (i.e. `"a"^3` gives us
`"a" * "a" * "a"` so `"aaa"`). `getProgressBar` accepts percentage (`perc`) and
draws as many vertical bars as `perc` tells us. The unused spots (`100-perc`)
are filed with the placeholders (`"."`). We finish by appending the number
itself and the `%` symbol by using [string
interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).

Printing a string of 100 characters (actually a bit more) may not look good on
some terminals (by default many terminals are 80 characters wide). That is why
we may want to limit ourselves to a smaller value of characters
(`maxNumOfChars`) for the progress bar and rescale the percentage (`perc`)
accordingly (see below).

```jl
s3 = """
function getProgressBar(perc::Int)::Str
    @assert 0 <= perc <= 100 "perc must be in range [0-100]"
    maxNumOfChars::Int = 50
    p::Int = round(Int, perc / (100 / maxNumOfChars))
    return "|" ^ p * "." ^ (maxNumChars-p) * xxx
end
"""
replace(sc(s3), "xxx" => "\" \$perc%\"")
```

The above function looses some resolution in translation of `perc` to vertical
bars (`|`). However, the percentage is displayed as a number anyway (`" $perc%"`)
so it is not such a big problem after all.

Now, we are ready to write the first version of our `animateProgressBar`.

```
function animateProgressBar()::Nothing
    fans::Vec{Str} = ["\\", "-", "/", "-"]
    lenFans::Int = length(fans)
    for p in 0:100
        println(getProgressBar(p), " ", fans[(p % lenFans) + 1])
    end
    println(getProgressBar(100))
    return nothing
end
```

The function is rather simple. For every value of percentage (`for p in 0:100`)
we draw the progress bar with a fan that changes into one of four positions
(alternating `\`, `-`, `/`, `-` in one place a few times a second will give the
impression of a fan). Note, the double
[backslash](https://en.wikipedia.org/wiki/Backslash) character (`"\\"`) in
`fans`. The `\` symbol got a particular meaning in programming. It is used to
designate that the next character(s) is/are special. For instance
`println("and")` will just print the conjunction 'and'. On the other hand,
`println("a\nd")` will print 'a' and 'd', one below the other, since in Julia
`"\n"` stands for newline. To get rid of the special meaning of `"\"` we precede
it with another backslash, hence `"\\"`. As for the indices of `fans` we use the
modulo operator and its property (`a % b` takes values in the range `[0-b)`,
hence `(p % lenFans) + 1`) as explained e.g in @sec:the_answer_solution.

OK, let's see what we got.

```
animateProgressBar()
```

```
.................................................. 0% \
.................................................. 1% -
|................................................. 2% /
||................................................ 3% -
||................................................ 4% \
||................................................ 5% -
# part of the output trimmed
||||||||||||||||||||||||||||||||||||||||||||||||.. 96%\
||||||||||||||||||||||||||||||||||||||||||||||||.. 97%-
|||||||||||||||||||||||||||||||||||||||||||||||||. 98%/
|||||||||||||||||||||||||||||||||||||||||||||||||| 99%-
|||||||||||||||||||||||||||||||||||||||||||||||||| 100%\
|||||||||||||||||||||||||||||||||||||||||||||||||| 100%
```

Pretty good. However, there is a small problem. Namely, the output is printed on
the screen instantaneously with one line beneath the other. The first problem
will be solved with
[sleep](https://docs.julialang.org/en/v1/base/parallel/#Base.sleep) that makes
the program wait for a specific number of seconds before executing the next line
of code. The second problem will be solved with [ANSI escape
codes](https://en.wikipedia.org/wiki/ANSI_escape_code) a sequence of characters
with a special meaning [as found in the link to the Wikipedia's page].

```
# the terminal must support ANSI escape codes
# https://en.wikipedia.org/wiki/ANSI_escape_code
function clearPrintout()::Nothing
    #"\033[xxxA" - xxx moves cursor up xxx lines
    print("\033[1A")
    # clears from cursor position till end of display
    print("\033[J")
	return nothing
end

function animateProgressBar()::Nothing
    delaySec::Flt = 0.1
    fans::Vec{Str} = ["\\", "-", "/", "-"]
    lenFans::Int = length(fans)
    for p in 0:100
        delaySec = rand(0.1:0.01:0.25)
        println(getProgressBar(p), " ", fans[(p % lenFans) + 1])
        sleep(delaySec) # sleep accepts delay in seconds
        clearPrintout()
    end
    println(getProgressBar(100))
    return nothing
end
```

This time running `animateProgressBar()` will give us the desired result.

As a final touch we will add some functionality for running our script (saved as
`progress_bar.jl`) from a
[terminal](https://en.wikipedia.org/wiki/Terminal_emulator).

```
function main()::Nothing
    println("Toy program.")
    println("It animates a progress bar.")
    println("Note: your terminal must support ANSI escape codes.\n")

    # y(es) - default choice (also with Enter), anything else: no
    println("Continue with the animation? [Y/n]")
    choice::Str = readline()
    if lowercase(strip(choice)) in ["y", "yes", ""]
        animateProgressBar()
    end

    println("\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
```

Although not strictly required in Julia, the `main` function is by convention a
starting point of any (big or small) program (in many programming
languages). Whereas the `if abspath` part makes sure that our `main` function is
run only if the program was called directly from the terminal, i.e.

```shell
julia progress_bar.jl
```

will run it, while:

```shell
julia other_file_that_imports_progress_bar.jl
```

will not.
