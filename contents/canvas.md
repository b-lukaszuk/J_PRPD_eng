# Canvas {#sec:canvas}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/canvas)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:canvas_problem}

Create a simple pixel-art
[terminal](https://en.wikipedia.org/wiki/Terminal_emulator) graphics. You may,
e.g. draw a house on a meadow that is similar to the one below.

![An exemplary pixel-art terminal graphics made with Julia.](./images/canvas.png){#fig:canvas}

## Solution {#sec:canvas_solution}

The first question to answer is how to represent our `canvas`. Here, we'll
go with a matrix of strings which we will tint by placing space characters (`"
"`) on a background colored with [ANSI escape
codes](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

```
const PIXEL = " "

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

canvas = fill(getBgColor(:gray), 30, 60)
```

> Note. Using `const` with mutable containers like vectors or dictionaries
> allows to change their contents later on, e.g., with `push!`. So the `const`
> used here is more like a convention, a signal that we do not plan to change
> the containers in the future. If we really wanted an immutable container then
> we should consider a(n) (immutable) tuple. Anyway, some programming languages
> suggest that `const` names should be declared using all uppercase characters
> to make them stand out. Here, I follow this convention.

Next, we want a way to properly display canvas (`printCanvas`) and to clear it
(`clearCanvas!`). This last method will allow us to erase an incorrect drawing
and try again and again if we need to.

```
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
```

Now, to draw a picture we will need a few shapes, most likely: a rectangle, a
triangle and an oval/circle. A shape will be represented as a vector of
positions in our matrix (`canvas`). The positions need to be dyed with a
specific color to visualize an object. Let's start with a rectangle as this
should be the easiest shape to obtain.

```
const COORD_ORIGIN = (1, 1) # origin or the coordinate system (row, col)

const Pos = Tuple{Int, Int} # position, (row, col) in canvas

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
```

Each `rectangle` is represented as a vector of positions (`Vec{Pos}`). It will
start at the origin of our coordinate system (`COORD_ORIGIN` - top left corner
of our matrix). It will spread through as many `row`s and `col`umns as there are
needed. Their numbers will be calculated based on the `height` and `width` of
the rectangle. Such a rectangle (the one that starts in the coordinate system
origin point) is a good start, but to draw a picture we need to be able to place
a shape in any location on the canvas.

```
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
```

So far so good. Time to find a way to add the points that build our shape to the
canvas (notice, that we only add the points that are inside of our canvas).

```
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
```

Notice `!` character in `addPoints!`. Per Julia's convention it was added to the
name of the function that modifies its contents. However, both `shape`
(`Vec{Pos}`) and `cvs` (`Matrix{Str}`) are passed by reference. So a question
may arise which one of the two (or maybe both) will get modified. To help with
the answer the second parameter was named `cvs!` to emphasize that only it will
be modified by the function (the `!` is just a part of the function's
parameter's name).

Once we got it we can move to another shape, i.e. a triangle.

```
function getTriangle(height::Int)::Vec{Pos}
    @assert height > 1 "height must be > 1"
    rowStart::Int, colStart::Int = COORD_ORIGIN
    lCol::Int = colStart # 1
    rCol::Int = colStart # 2
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
```

Our triangle's top starts with a pixel (`lCol` and `rCol` are initialized with
the same value) in the origin of our coordinate system (`COORD_ORIGIN`). Then
for each row (`for row in rowStart:height`) we dye each pixel between the left
(`lCol`) and right (`rCol`) columns (inclusive-inclusive). The basis of the
triangle is increased by one pixel on each side (`lCol -= 1` and `rCol += 1`)
with each row we move down. Of note, we could have shortened the above snippet,
e.g. by using a [C](https://en.wikipedia.org/wiki/C_(programming_language))-like
chained assignment (`lCol = rCol = colStart` instead of lines `#1` and
`#2`). However, the longer version might be clearer and easier to follow in a
head.

There's one more shape left, a circle.

```
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
```

Here, we use a pattern similar to the one from the triangle. A circle is started
in the top row (`rowStart`) with three columns (`collect((-1-r):(2+r))`). With
every row down we increase the spread by 1 column in each direction (`r` changes
by 1). Once, we are in half of our circle we decrease the number of colored
columns. We achieve that by combining the previous `cols` with their `reverse`d
version (`...` is a splat operator that, unpacks a vector by copying its
elements).

Finally, we proceed to create our pixel-art graphics, e.g. by iteratively adding
one element at a time with something like:

```
clearCanvas!()
addPoints!(getSomeShape, :someColor)
printCanvas()
```

and

```
clearCanvas!()
addPoints!(getSomeShape, :someColor)
addPoints!(getAnotherShape, :someOtherColor)
printCanvas()
```

Until we reach a satisfactory result with a code snippet similar to the one
below:

```
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
```
