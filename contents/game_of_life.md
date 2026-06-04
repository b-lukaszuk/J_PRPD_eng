# Game of Life {#sec:game_of_life}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/game_of_life)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:game_of_life_problem}

Let's finish with another classic. This time your job is to implement [Conway's
Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) with a
finite two dimensional grid called the universe. Each cell on the grid got some
initial probability of being alive. Per the Wikipedia's description the next
state of the universe is calculated as follows:

> 1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
> 2. Any live cell with two or three live neighbours lives on to the next generation.
> 3. Any live cell with more than three live neighbours dies, as if by overpopulation.
> 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

The game may look something like @fig:gameOfLife.

![A frame from the Conway's Game of Life.](./images/gameOfLife.png){#fig:gameOfLife}

> **_WARNING:_** While running the program in terminal the screen may
> flicker. If that's a problem (you may feel unwell) then you can skip this
> exercise. Remember that you should be able to abort the program (terminal
> application) at any time by pressing Ctrl-C.

## Solution {#sec:game_of_life_solution}

Let's start with our universe.

```jl
s = """
N_COLS = 80
N_ROWS = 40
PROB_ALIVE = 0.25

Universe = Matrix{Bool}

function getEmptyUniverse()::Universe
    return zeros(Bool, N_ROWS, N_COLS)
end

function getRandUniverse()::Universe
	# rand gives val [0-1) and not [0-1] like prob, but it will do
    return rand(Float64, N_ROWS, N_COLS) .<= PROB_ALIVE
end
"""
replace(sc(s), "N_COLS =" => "const N_COLS =", "N_ROWS =" => "const N_ROWS =",
	"PROB_ALIVE =" => "const PROB_ALIVE =", "Universe =" => "const Universe =")
```

For that we defined a few `const`ants and functions. The `Universe` data type,
is a synonym for a `Matrix` (`N_ROWS`x`N_COLS`) of `Bool`s. This is a natural
choice since each cell can be either alive (with the probability of `0.25`) or
dead.

Notice that above we used `const`ants. For a small self-contained project like
this it is OK as it simplifies the code. For more serious applications you may
consider creating a config file/struct and use it like:

```
struct Config
    nCols::Int
    nRows::Int
	# possibly some other fields
end

config = Config(80, 40) # or read config from a file into the struct

function getEmptyUniverse(conf::Config = config)::Matrix{Bool}
    return zeros(Bool, conf.nRows, conf.nCols)
end
```

Anyway, for simplicity, here I go with the excessive? use of `const`s, which are
placed 'when needed' in order to fit with the flow of the text. However, for
readability and code maintenance I recommend all the `const`s to be defined at a
top of a `*.jl` file (like in [the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/game_of_life)).

Enough for the detour, time for printing.

```jl
s = """
ALIVE_SYMBOL = 'O'
DEAD_SYMBOL = '.'
N_GENERATIONS = 50

function getFieldSymbol(field::Bool)::Char
    return field ? ALIVE_SYMBOL : DEAD_SYMBOL
end

function printUniverse(universe::Universe, nGeneration::Int)::Nothing
    population::Int = sum(universe)
    print("Generation: \$nGeneration/\$N_GENERATIONS, ")
	println("population: \$population\\n")
    for r in 1:N_ROWS
        println(map(getFieldSymbol, universe[r, :]) |> join)
    end
    return nothing
end

# https://en.wikipedia.org/wiki/ANSI_escape_code
function clearDisplay(nLinesUp::Int)::Nothing
    @assert 0 < nLinesUp "nLinesUp must be a positive integer"
    # "\\033[xxxA" - xxx moves cursor up xxx LINES
    print("\\033[" * string(nLinesUp) * "A")
    # "\\033[0J" - clears from cursor position till the end of the screen
    print("\\033[0J")
    return nothing
end

function reprintUniverse(universe::Universe, nGeneration::Int)::Nothing
    clearDisplay(N_ROWS+2) # +2 cause info line and newline
    printUniverse(universe, nGeneration)
    return nothing
end
"""
replace(sc(s), "ALIVE_SYMBOL =" => "const ALIVE_SYMBOL =",
	"DEAD_SYMBOL =" => "const DEAD_SYMBOL =",
	"N_GENERATIONS =" => "const N_GENERATIONS =")
```

The above (printing and reprinting) is basically a modified code from
@sec:diffusion_solution. Of note, here we do not draw the borders, instead we
use dead (`DEAD_SYMBOL`) and live (`ALIVE_SYMBOL`) cells.

Time to determine the next state of our `universe`. But first we need to know
the number of a cell's neighbors that are alive.

```jl
s = """
function isCellWithinRange(row::Int, col::Int)::Bool
    return (1 <= row <= N_ROWS) && (1 <= col <= N_COLS)
end

function getNumLiveNeighbors(universe::Universe, row::Int, col::Int)::Int
    if !isCellWithinRange(row, col)
        return 0
    end
    nAlive::Int = 0
    neighborCol::Int, neighborRow::Int = 0, 0
    for colShift in -1:1, rowShift in -1:1
        neighborRow, neighborCol = row+rowShift, col+colShift
        if !isCellWithinRange(neighborRow, neighborCol)
            continue
        end
        if (neighborRow == row && neighborCol == col)
            continue
        end
        if universe[neighborRow, neighborCol]
            nAlive += 1
        end
    end
    return nAlive
end
"""
sc(s)
```

We assign this task to `getNumLiveNeighbors` that accepts our `universe` and the
cell of interest coordinates (`row` and `col`) as its parameters. The neighbors
of a cell are located in a row below, the same row as the cell, and a row above
the cell's own row (`rowShift in -1:1`). Similarly, we look at a column to the
left, the same column as the cell, and a column to the right of the cell's own
column (`colShift in -1:1`). Hence, a neighbor's coordinates are calculated as
`neighborRow = row+rowShift` (`row` is the cell's own row) and `neighborCol =
col+colShift` (`col` is the cell's own column). We examine all the possible
neighbor locations with the `for` loop. If the coordinates fall outside the grid
(`!isCellWithinRange` - the cell does not exist in our `universe`) then we
`continue` to the next iteration (we examine the next coordinates). The same
goes for examining the coordinates of the cell itself (since both `rowShift` and
`colShift` may be equal to 0). Otherwise, if a neighbor is alive (`if
universe[neighborRow, neighborCol]`) we add 1 to the count (`nAlive += 1`),
which we eventually `return` from the function.

Now we are ready to calculate the next state of our `universe`.

```jl
s = """
function shouldCellBeAlive(universe::Universe, row::Int, col::Int)::Bool
    nLiveNeighbors::Int = getNumLiveNeighbors(universe, row, col)
    if universe[row, col] && nLiveNeighbors in 2:3
        return true
    end
    return !universe[row, col] && nLiveNeighbors == 3
    # here the below is sufficient (unless you avoid too clever code)
    # return nLiveNeighbors == 3
end

function getUniverseNextState(universe::Universe)::Universe
    newUniverse::Universe = getEmptyUniverse()
    for c in 1:N_COLS, r in 1:N_ROWS
        newUniverse[r, c] = shouldCellBeAlive(universe, r, c)
    end
    return newUniverse
end
"""
sc(s)
```

We start by figuring out if a cell should be alive in the next turn
(`shouldCellBeAlive`). Per task specification, if a cell was previously alive
(`if universe[row, col]`) and it got 2 or 3 live neighbors (`nLiveNeighbors in
2:3`) then it should be alive (`return true`). Otherwise, it should live if it
was previously dead (`!universe[row, col]`) and got exactly three live neighbors
(`nLiveNeighbors == 3`).

All that's left to do is to `getUniverseNextState` by examining each cell (`r`
and `c`) in the `universe` and deciding its fate in the next turn
(`shouldCellBeAlive(universe, r, c)`).

And now for the final touch.

```jl
s = """
DELAY_SEC = 0.5

# early stop
function areAllCellsDead(universe::Universe)::Bool
    return sum(universe) == 0
end

function runGameOfLife()
    universe::Universe = getRandUniverse()
    printUniverse(universe, 0)
    for nGeneration in 1:N_GENERATIONS
        universe = getUniverseNextState(universe)
        reprintUniverse(universe, nGeneration)
        sleep(DELAY_SEC)
        if areAllCellsDead(universe)
            println("All cells are dead.")
            break
        end
    end
end
"""
replace(sc(s), "DELAY_SEC =" => "const DELAY_SEC =")
```

Let the games begin (type `runGameOfLife()` and see what happens).
