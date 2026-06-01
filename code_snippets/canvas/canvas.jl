# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Pos = Tuple{Int, Int} # position, (row, col) in canvas
const Str = String
const Vec = Vector

const PIXEL = " " # empty string, because we set background color
const COORD_ORIGIN = (1, 1) # origin of the coordinate system (row, col)

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# "\x1b[48:5:XXXm" sets background color to XXX color code (256-color mode)
const BG_COLORS = Dict(
    :gray => "\x1b[48:5:8m",
    :white => "\x1b[48:5:15m",
    :red => "\x1b[48:5:160m",
    :yellow => "\x1b[48:5:11m",
    :blue => "\x1b[48:5:12m",
    :darkblue => "\x1b[48:5:20m",
    :green => "\x1b[48:5:35m",
    :black => "\x1b[48:5:0m",
    :brown => "\x1b[48:5:88m",
)

# "\x1b[0m" resets background color to default value
# default color: "\x1b[48:5:13m" - pink
function getBgColor(color::Symbol,
                    colors::Dict{Symbol, Str}=BG_COLORS,
                    defColor::Str="\x1b[48:5:13m")::Str
    return get(colors, color, defColor) * PIXEL * "\x1b[0m"
end

canvas = fill(getBgColor(:gray), 30, 60);

function printCanvas(cvs::Matrix{Str}=canvas)::Nothing
    nRows, _ = size(cvs)
    for r in 1:nRows
        println(cvs[r, :] |> join)
    end
    return nothing
end

function clearCanvas!(cvs::Matrix{Str}=canvas)::Nothing
    cvs .= getBgColor(:gray)
    return nothing
end

function getRectangle(width::Int, height::Int)::Vec{Pos}
    @assert width >= 2 "width must be >= 2"
    @assert height >= 2 "height must be >= 2"
    rectangle::Vec{Pos} = Vec{Pos}(undef, width * height)
    rowStart::Int, colStart::Int = COORD_ORIGIN
    i::Int = 1
    for row in rowStart:height, col in colStart:width
        rectangle[i] = (row, col)
        i += 1
    end
    return rectangle
end

# moves a shape by (nRows, nCols)
function nudge(shape::Vec{Pos}, by::Pos)::Vec{Pos}
    return map(pos -> pos .+ by, shape)
end

# shifts a shape so that its anchor point starts where we want
function shift(shape::Vec{Pos}, anchor::Pos)::Vec{Pos}
    shift::Pos = anchor .- COORD_ORIGIN
    return nudge(shape, shift)
end

function getRectangle(width::Int, height::Int, topLeftCorner::Pos)::Vec{Pos}
    return shift(getRectangle(width, height), topLeftCorner)
end

function isWithinCanvas(point::Pos, cvs::Matrix{Str}=canvas)::Bool
    nRows, nCols = size(cvs)
    row, col = point
    return (0 < row <= nRows) && (0 < col <= nCols)
end

function addPoints!(shape::Vec{Pos}, color::Symbol,
                    cvs!::Matrix{Str}=canvas)::Nothing
    for pt in shape
        if isWithinCanvas(pt, cvs!)
            cvs![pt...] = getBgColor(color)
        end
    end
    return nothing
end

function getTriangle(height::Int)::Vec{Pos}
    @assert height > 1 "height must be > 1"
    rowStart::Int, colStart::Int = COORD_ORIGIN
    lCol::Int = colStart
    rCol::Int = colStart
    triangle::Vec{Pos} = []
    for row in rowStart:height
        for col in lCol:rCol
            push!(triangle, (row, col))
        end
        lCol -= 1
        rCol += 1
    end
    return triangle
end

function getTriangle(height::Int, apex::Pos)::Vec{Pos}
    return shift(getTriangle(height), apex)
end

function getCircle(radius::Int)::Vec{Pos}
    @assert 1 < radius < 6 "radius must be in range [2-5]"
    cols::Vec{Vec{Int}} = [collect((-1-r):(2+r)) for r in 0:(radius-1)]
    cols = [cols..., reverse(cols)...]
    circle::Vec{Pos} = []
    rowStart::Int, _ = COORD_ORIGIN
    for row in rowStart:(radius*2)
        for col in cols[row]
            push!(circle, (row, col))
        end
    end
    return circle
end

function getCircle(radius::Int, topCenter::Pos)::Vec{Pos}
    return shift(getCircle(radius), topCenter)
end

# final drawing
clearCanvas!()
addPoints!(getRectangle(60, 15, (16, 1)), :green) # meadow
addPoints!(getRectangle(60, 15), :blue) # sky
addPoints!(getRectangle(15, 8, (15, 21)), :white) # house walls
addPoints!(getRectangle(6, 6, (17, 28)), :brown) # doors
addPoints!(getRectangle(4, 2, (16, 22)), :darkblue) # window
addPoints!(getRectangle(4, 6, (8, 31)), :black) # chimney
addPoints!(getTriangle(8, (7, 28)), :red) # roof
addPoints!(getCircle(4, (2, 55)), :yellow) # sun
addPoints!(getCircle(3, (4, 7)), :white) # cloud, part 1
addPoints!(getCircle(4, (4, 14)), :white) # cloud, part 2
addPoints!(getCircle(2, (2, 18)), :white) # cloud, part 3
printCanvas()
