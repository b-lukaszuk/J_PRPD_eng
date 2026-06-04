# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# custom data types (type synonyms)
const Flt = Float64
const Pos = Tuple{Int, Int} # position (row, col) in 2D container
const Str = String
const Vec = Vector

# just constants
const DELAY_SEC = 0.1
const N_CYCLES = 2_500
const SECS_PER_MIN = 60
const DURATION_SEC = DELAY_SEC * N_CYCLES
const DURATION_MIN = DURATION_SEC / SECS_PER_MIN
const N_COLS = 80
const N_ROWS = 40
const MOLECULE = '.'
const N_MOLECULES = 150

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

function isWithinContainer(molecule::Pos)::Bool
    row, col = molecule
    # accounts for borders
    return (1 < row < N_ROWS) && (1 < col < N_COLS)
end

function emptyContainer!(container::Matrix{Char})::Nothing
    for c in 1:N_COLS, r in 1:N_ROWS
        if isWithinContainer((r, c))
            container[r, c] = ' '
        end
    end
    return nothing
end

# assumption: molecules may pass through each other
# (or occupy the same pixel in 2D), since they move past each other
# in the third (not drawn) dimension
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

function addMolecules2container!(molecules::Vec{Pos},
                                 container!::Matrix{Char})::Nothing
    for molecule in molecules
        if isWithinContainer(molecule)
            container![molecule...] = MOLECULE
        end
    end
    return nothing
end

round2int(f::Flt)::Int = round(Int, f)

function getNewPosition(molecule::Pos)::Pos
    rowShift::Int = randn() |> round2int
    colShift::Int = randn() |> round2int
    return molecule .+ (rowShift, colShift)
end

# assumption: molecules may pass through each other (or occupy the same pixel in 2D)
# since they move past each other in the third (not drawn) dimension
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

function clearDisplay(nLinesUp::Int)::Nothing
    @assert 0 < nLinesUp "nLinesUp must be a positive integer"
    # "\033[xxxA" - xxx moves cursor up xxx LINES
    print("\033[" * string(nLinesUp) * "A")
    # "\033[0J" - clears from cursor position till the end of the screen
    print("\033[0J")
    return nothing
end

getCol((_, c)::Pos)::Int = c

function getRightLeftCountsInfo(molecules::Vec{Pos})::Str
    colsWithMolecules::Vec{Int} = map(getCol, molecules)
    midCol::Int = round2int(N_COLS/2)
    lCount::Int = sum(colsWithMolecules .<= midCol)
    rCount::Int = sum(colsWithMolecules .> midCol)
    return "Left count: $lCount | Right count: $rCount"
end

function redrawDisplay(container::Matrix{Char},
                       molecules::Vec{Pos},
                       nCycle::Int)::Nothing
    clearDisplay(N_ROWS+2) # container + 2 info lines below
    println("Cycle no: $nCycle/$N_CYCLES")
    println(getRightLeftCountsInfo(molecules))
    printContainer(container)
    return nothing
end

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

rnd2(x::Flt)::Flt = round(x, digits=2)

function main()::Nothing
    println("\nThis is a toy program that models simplified diffusion.")
    println("Note: your terminal must support ANSI escape codes.\n")

    println("Estimated execution time of the program:")
    println("$(rnd2(DURATION_SEC)) seconds or $(rnd2(DURATION_MIN)) minutes.")
    println("WARNING: the screen may flicker (Ctrl-C should abort the program).")

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
