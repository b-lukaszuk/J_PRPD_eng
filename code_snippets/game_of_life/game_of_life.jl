# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
const N_COLS = 80
const N_ROWS = 40
const PROB_ALIVE = 0.25
const ALIVE_SYMBOL = 'O'
const DEAD_SYMBOL = '.'
const DELAY_SEC = 0.5
const N_GENERATIONS = 50

const Str = String
const Universe = Matrix{Bool}

function getEmptyUniverse()::Universe
    return zeros(Bool, N_ROWS, N_COLS)
end

function getRandUniverse()::Universe
    return rand(Float64, N_ROWS, N_COLS) .<= PROB_ALIVE
end

function getFieldSymbol(field::Bool)::Char
    return field ? ALIVE_SYMBOL : DEAD_SYMBOL
end

function printUniverse(universe::Universe, nGeneration::Int)::Nothing
    population::Int = sum(universe)
    println("Generation: $nGeneration/$N_GENERATIONS, population: $population\n")
    for r in 1:N_ROWS
        println(map(getFieldSymbol, universe[r, :]) |> join)
    end
    return nothing
end

# https://en.wikipedia.org/wiki/ANSI_escape_code
function clearDisplay(nLinesUp::Int)::Nothing
    @assert 0 < nLinesUp "nLinesUp must be a positive integer"
    # "\033[xxxA" - xxx moves cursor up xxx LINES
    print("\033[" * string(nLinesUp) * "A")
    # "\033[0J" - clears from cursor position till the end of the screen
    print("\033[0J")
    return nothing
end

function reprintUniverse(universe::Universe, nGeneration::Int)::Nothing
    clearDisplay(N_ROWS+2) # +2 cause info line and newline
    printUniverse(universe, nGeneration)
    return nothing
end

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

# make sure your terminal supports ANSI escape codes
# if you need it: Ctrl-C should abort the game
runGameOfLife()
