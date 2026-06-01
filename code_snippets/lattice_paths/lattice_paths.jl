import CairoMakie as Cmk

const Vec = Vector
const Flt = Float64

const Pos = Tuple{Int, Int}
const Mov = Tuple{Int, Int}
const Path = Vector{Pos}

const RIGHT = (1, 0)
const DOWN = (0, -1)
const MOVES = [RIGHT, DOWN]
const START_POINT = (0, 0) # top left corner

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

function add(position::Pos, move::Mov)::Pos
    return position .+ move
end

function add(positions::Vec{Pos}, moves::Vec{Mov}=MOVES)::Vec{Pos}
    @assert !isempty(positions) "positions cannot be empty"
    @assert !isempty(moves) "moves cannot be empty"
    result::Vec{Pos} = []
    for p in positions, m in moves
        push!(result, add(p, m))
    end
    return result
end

function getFinalPositions(nRows::Int)::Vec{Pos}
    @assert 0 < nRows < 5 "nRows must be in the range [1-4]"
    finalPositions::Vec{Pos} = [START_POINT] # top left corner
    for _ in 1:(nRows*2) # - *2 - because of columns
        finalPositions = add(finalPositions, MOVES)
    end
    return finalPositions
end

function getNumOfPaths(nRows::Int)::Int
    @assert 0 < nRows < 5 "nRows must be in the range [1-4]"
    target::Pos = (nRows, -nRows) # bottom right corner
    positions::Vec{Pos} = getFinalPositions(nRows)
    return filter(pos -> pos == target, positions) |> length
end

getNumOfPaths.(1:4)
all([getNumOfPaths(i) == binomial(2*i, i) for i in 1:4])

function makeOneStep(prevPaths::Vec{Path}, moves::Vec{Mov}=MOVES)::Vec{Path}
    @assert !isempty(prevPaths) "prevPaths cannot be empty"
    @assert !isempty(moves) "moves cannot be empty"
    result::Vec{Path} = []
    for path in prevPaths, move in moves
        push!(result, [path..., add(path[end], move)])
    end
    return result
end

function getPaths(nRows::Int)::Vec{Path}
    @assert 0 < nRows < 5 "nRows must be in the range [1-4]"
    target::Pos = (nRows, -nRows) # bottom right corner
    result::Vec{Path} = [[START_POINT]] # top left corner
    for _ in 1:(nRows*2) # - *2 - because of columns
        result = makeOneStep(result, MOVES)
    end
    return filter(path -> path[end] == target, result)
end

# some tests
paths = getPaths(1)
binomial(2, 1)

paths = getPaths(2)
binomial(4, 2)

paths = getPaths(3)
binomial(6, 3)

paths = getPaths(4)
binomial(8, 4)

function getDirection(p1::Pos, p2::Pos)::Mov
    return p2 .- p1
end

function getDirections(path::Path)::Vec{Mov}
    return map(getDirection, path[1:end-1], path[2:end])
end

function addGrid!(ax::Cmk.Axis,
                  xmin::Int=0, xmax::Int=2, ymin::Int=-2, ymax::Int=0)::Nothing
    @assert xmin < xmax "xmin must be < xmax"
    @assert ymin < ymax "ymin must be < ymax"
    for yCut in ymin:ymax
        Cmk.lines!(ax, [xmin, xmax], [yCut, yCut], color=:blue, linewidth=1)
    end
    for xCut in xmin:xmax
        Cmk.lines!(ax, [xCut, xCut], [ymin, ymax], color=:blue, linewidth=1)
    end
    return nothing
end

function drawPaths(paths::Vec{Path}, nCols::Int)::Cmk.Figure
    @assert length(paths) % nCols == 0 "length(paths) % nCols is not 0"
    r::Int, c::Int = 1, 1 # r - row, c - column of subFig on Figure
    sp::Flt = 0.5 # extra space on X/Y axis for better look
    xmin::Int, xmax::Int = paths[1][1][1], paths[1][end][1]
    ymax::Int, ymin::Int = paths[1][1][2], paths[1][end][2]
    fig::Cmk.Figure = Cmk.Figure()
    for path in paths
        ax = Cmk.Axis(fig[r, c],
                      limits=(xmin-sp, xmax+sp, ymin-sp, ymax+sp),
                      aspect=1, xticklabelsize=10, yticklabelsize=10)
        Cmk.hidespines!(ax)
        Cmk.hidedecorations!(ax)
        directions::Vec{Mov} = getDirections(path)
        points::Vec{Pos} = path[1:end-1]
        addGrid!(ax, xmin, xmax, ymin, ymax)
        Cmk.arrows2d!(ax, points, directions)
        if c == nCols
            r += 1
            c = 1
        else
            c += 1
        end
    end
    Cmk.rowgap!(fig.layout, Cmk.Fixed(1))
    Cmk.colgap!(fig.layout, Cmk.Fixed(1))
    return fig
end

# some tests (figures may take a few seconds to be drawn)
paths = getPaths(1)
drawPaths(paths, 2)

paths = getPaths(2)
drawPaths(paths, 3)

paths = getPaths(3)
# drawPaths(paths, 4)
drawPaths(paths, 5)

# may take a dozen of seconds to execute
paths = getPaths(4)
# drawPaths(paths, 7)
drawPaths(paths, 10)
