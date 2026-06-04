# Diffusion {#sec:diffusion}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/diffusion)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:diffusion_problem}

This time your job is to write a simplified
[diffusion](https://en.wikipedia.org/wiki/Diffusion) simulator. It may or may
not be a terminal app (mine runs in a terminal).

For that purpose create a container (let's say 40x80) and fill its left half
with let's say 150 molecules (like in @fig:diffusionFirstFrame) that are sped by
[Brownian motion](https://en.wikipedia.org/wiki/Brownian_motion). See if the
diffusion works, by comparing initial distribution of particles with the
distribution after a few thousand cycles. To make it simpler you don't have to
handle the collisions between the molecules (assume they pass each other in the
third dimension), but make sure they won't go out of the container.

> **_WARNING:_** While running the program in a terminal the screen may
> flicker. If that's a problem (you may feel unwell) then you can skip this
> exercise. Remember that you should be able to abort the program (terminal
> application) at any time by pressing Ctrl-C.

![Simplified diffusion simulation (initial frame).](./images/diffusionFirstFrame.png){#fig:diffusionFirstFrame}

## Solution {#sec:diffusion_solution}

Let's start with the container and its functionality.

```jl
s = """
N_COLS = 80
N_ROWS = 40

function addBorders!(container::Matrix{Char})::Nothing
    container[:, 1] .= '|'
    container[:, N_COLS] .= '|'
    container[1, :] .= '-'
    container[N_ROWS, :] .= '-'
    return nothing
end

function getEmptyContainer()::Matrix{Char}
    container::Matrix{Char} = fill(' ', N_ROWS, N_COLS);
    addBorders!(container)
    return container
end

function printContainer(container::Matrix{Char})::Nothing
    for r in 1:N_ROWS
        println(container[r, :] |> join)
    end
    return nothing
end

function clearDisplay(nLinesUp::Int)::Nothing
    @assert 0 < nLinesUp "nLinesUp must be a positive integer"
    # "\\033[xxxA" - xxx moves cursor up xxx LINES
    print("\\033[" * string(nLinesUp) * "A")
    # "\\033[0J" - clears from cursor position till the end of the screen
    print("\\033[0J")
    return nothing
end
"""
replace(sc(s), "N_COLS =" => "const N_COLS =", "N_ROWS =" => "const N_ROWS =")
```

The `container` is just a `Matrix` (a table) of characters (`Chars`) that's
constrained by the borders (`|` and `-`) and initially contains nothing inside
(`fill(' ', N_ROWS, N_COLS)`).

Notice that in this chapter we will use `const`ants quite a bit. For a small
self-contained project like this it is OK as it simplifies the code. For more
serious applications you may consider creating a config file/struct and use it
like:

```
struct Config
    nCols::Int
    nRows::Int
	# possibly some other fields
end

config = Config(80, 40) # or read config from a file into the struct

function getEmptyContainer(conf::Config = config)::Matrix{Char}
	container::Matrix{Char} = fill(' ', conf.nRows, conf.nCols);
    addBorders!(container, conf)
    return container
end
```

Anyway, let's leave the discussion on a program design and get to the program
itself.

Now we need our `molecules`. The above will be defined as a vector of positions
denoting their locations (row and column) within the matrix (our `container`).

```jl
s = """
Pos = Tuple{Int, Int} # position (row, col) in 2D container

function isWithinContainer(molecule::Pos)::Bool
    row, col = molecule
    # accounts for borders
    return (1 < row < N_ROWS) && (1 < col < N_COLS)
end
"""
replace(sc(s), "Pos =" => "const Pos =")
```

At first `molecules` will occupy random positions.

```jl
s = """
# assumption: molecules may pass through each other
# (or occupy the same pixel in 2D) since they move
# past each other in the third (not drawn) dimension
function placeMoleculesRandomly!(molecules::Vec{Pos},
                                 rowMin::Int, rowMax::Int,
                                 colMin::Int, colMax::Int)::Nothing
    @assert(isWithinContainer((rowMin, colMin)),
            "(rowMin, colMin) outside of container")
    @assert(isWithinContainer((rowMax, colMax)),
            "(rowMax, colMax) outside of container")
    r::Int, c::Int = 0, 0
    for i in eachindex(molecules)
        r = rand(rowMin:rowMax)
        c = rand(colMin:colMax)
        molecules[i] = (r, c)
    end
    return nothing
end

const MOLECULE = '.'

function addMolecules2container!(molecules::Vec{Pos},
                                 container!::Matrix{Char})::Nothing
    for molecule in molecules
        if isWithinContainer(molecule)
            container![molecule...] = MOLECULE
        end
    end
    return nothing
end
"""
sc(s)
```

Using `rowMin`/`rowMax`, `colMin`/`colMax` allows to place the molecules only in
some part of the matrix (per task specification it will be the left side of
`container`). Notice `!` character in `addMolecules2container!`. Per Julia's
convention it was added to the name of the function that modifies its
contents. However, both `molecules` (`Vec{Pos}`) and `container`
(`Matrix{Char}`) are passed by reference. So a question may arise which one of
the two (or maybe both) will get modified. To help with the answer the second
parameter was named `container!` to emphasize that only it will be modified by
the function. On the other hand, `placeMoleculesRandomly!` may modify at most
one of its arguments (`molecules`) so there is no need for an extra `!` which
might be confusing at first glance. Anyway, the key thing is that based on the
positions (`molecules`) we placed a marker `MOLECULE = '.'` in our `container`
which later on will be displayed to the user.

Time to implement [Brownian
motion](https://en.wikipedia.org/wiki/Brownian_motion) or:

> [...] a normal distribution with the mean $\mu = 0$ and variance $\sigma^{2} =
> 2Dt$ usually called Brownian motion $B_{t}$ [...]

> (quote from the Wiki link provided above)

Here, we are OK with all the molecules being identical (and sharing identical
properties). Moreover, for simplicity we'll just assume that `D = 0.5` and `t =
1` (for now, we don't much care what they are), hence `2Dt = 1`. This last
action will give us [a normal
distribution](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_normal_distribution.html)
with the mean $\mu = 0$ and variance $\sigma^{2} = 1$ (standard deviation `sd`
is also 1, since $sd = \sqrt{variance}$). Luckily, that is what the built-in
[randn](https://docs.julialang.org/en/v1/stdlib/Random/#Base.randn) function
provides. Hence, we will calculate the new position of a molecule to be
`new_position = old_position + shift` (`randn()` provides the shift) and
implement it like so:

```jl
s = """
round2int(f::Flt)::Int = round(Int, f)

function getNewPosition(molecule::Pos)::Pos
    rowShift::Int = randn() |> round2int
    colShift::Int = randn() |> round2int
    return molecule .+ (rowShift, colShift)
end

N_MOLECULES = 150

# assumption: molecules may pass through each other
# (or occupy the same pixel in 2D) since they move
# past each other in the third (not drawn) dimension
function make1BrownianCycleShift!(molecules::Vec{Pos})::Nothing
    i::Int = 1
    newPos::Pos = (0, 0)
    while i <= N_MOLECULES
        newPos = getNewPosition(molecules[i])
        if isWithinContainer(newPos)
            molecules[i] = newPos
            i += 1
        end
    end
    return nothing
end
"""
replace(sc(s), "N_MOLECULES =" => "const N_MOLECULES =")
```

Using a terminal display requires the shift to be an integer, hence `round2int`
implemented with a [single expression function
syntax](https://en.wikibooks.org/wiki/Introducing_Julia/Functions#Single_expression_functions).
Moreover, we cannot allow a particle to go outside the walls of the container,
thus the `if isWithinContainer(newPos), etc.` statement. Together with the
surrounding `while` block it makes sure that the molecule 'falls back' to the
container. Effectively, it kind of simulates a reflection of a molecule from the
walls of the vessel in a random direction.

Now we are almost ready for running our simulation, but first two rather
self-explanatory functions:

```jl
s = """
N_CYCLES = 2_500

getCol((_, c)::Pos)::Int = c

function getRightLeftCountsInfo(molecules::Vec{Pos})::Str
    colsWithMolecules::Vec{Int} = map(getCol, molecules)
    midCol::Int = round2int(N_COLS/2)
    lCount::Int = sum(colsWithMolecules .<= midCol)
    rCount::Int = sum(colsWithMolecules .> midCol)
    return "Left count: \$lCount | Right count: \$rCount"
end

function redrawDisplay(container::Matrix{Char},
                       molecules::Vec{Pos},
                       nCycle::Int)::Nothing
    clearDisplay(N_ROWS+2) # container + 2 info lines below
    println("Cycle no: \$nCycle/\$N_CYCLES")
    println(getRightLeftCountsInfo(molecules))
    printContainer(container)
    return nothing
end
"""
replace(sc(s), "N_CYCLES =" => "const N_CYCLES =")
```

Finally, crème de la crème, the simulation itself.

```jl
s = """
DELAY_SEC = 0.1

function simulateBrownianMotions(nCycles::Int=N_CYCLES)::Nothing
    @assert 500 <= nCycles <= 1e5 "nCycles must be in range [500, 1e5]"

    container::Matrix{Char} = getEmptyContainer()
    molecules::Vec{Pos} = fill((0, 0), N_MOLECULES)
    placeMoleculesRandomly!(molecules,
                            # adjusted for borders
                            2, N_ROWS-1,
                            2, round2int((N_COLS-2)/2)
                            )
    addMolecules2container!(molecules, container)
    redrawDisplay(container, molecules, 0)

    for cycleNumber in 1:nCycles
        make1BrownianCycleShift!(molecules)
        emptyContainer!(container)
        addMolecules2container!(molecules, container)
        sleep(DELAY_SEC)
        redrawDisplay(container, molecules, cycleNumber)
    end

    return nothing
end
"""
replace(sc(s), "DELAY_SEC =" => "const DELAY_SEC =")
```

Nothing special here, we just declare `container`/`molecules` and initialize
them with the appropriate values. Then, `for` each cycle `1:nCycles` we
`make1BrownianCycleShift`, remove the old molecule symbols from the `container`
(`emptyContainer`), add the symbols of new, shifted molecules
(`addMolecules2container`), pause for a moment (`sleep`) and redraw everything
(`redrawDisplay`).

All that's left to do is to add the `main` function since the app is meant to be
run from terminal.

```
const SECS_PER_MIN = 60
const DURATION_SEC = DELAY_SEC * N_CYCLES
const DURATION_MIN = DURATION_SEC / SECS_PER_MIN

rnd2(x::Flt)::Flt = round(x, digits=2)

function main()::Nothing
    println("\nThis is a toy program that models simplified diffusion.")
    println("Note: your terminal must support ANSI escape codes.\n")

    println("Estimated execution time of the program:")
    print("$(rnd2(DURATION_SEC)) seconds or $(rnd2(DURATION_MIN)) ")
	println("minutes.")
    print("WARNING: the screen may flicker ")
	println("(Ctrl-C should abort the program).")

    # y(es) - default choice (also with Enter), anything else: no
    println("\nContinue with the simulation? [Y/n]")
    choice::Str = readline()
    if lowercase(strip(choice)) in ["y", "yes", ""]
        simulateBrownianMotions()
    end

    println("\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
```

The end result is to be seen below (@fig:diffusionFinalFrame).

![Simplified diffusion simulation (final frame).](./images/diffusionFinalFrame.png){#fig:diffusionFinalFrame}

Amazing. So the diffusion works in the room you find yourself in and even in our
oversimplified simulation. All it took was a mock-up of Brownian motion, a
reflection from a wall of the container and a few thousand cycles of random
shifts to properly mix the particles.
