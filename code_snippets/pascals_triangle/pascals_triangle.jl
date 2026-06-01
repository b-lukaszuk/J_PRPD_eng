const Str = String
const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

function getSumOfPairs(prevRow::Vec{Int})::Vec{Int}
    @assert all(prevRow .> 0) "every element of prevRow must be > 0"
    return [a + b for (a, b) in zip(prevRow, prevRow[2:end])]
end

function getRow(prevRow::Vec{Int})::Vec{Int}
    @assert length(prevRow) > 1 "length(prevRow) must be > 1"
    sumsOfPairs::Vec{Int} = getSumOfPairs(prevRow)
    return [1, sumsOfPairs..., 1]
end

function getPascalTriangle(n::Int)::Vec{Vec{Int}}
    @assert 0 <= n <= 10 "n must be in range [0-10]"
    triangle::Dict{Int, Vec{Int}} = Dict(0 => [1], 1 => [1, 1])
    if !haskey(triangle, n)
        for row in 2:n
            triangle[row] = getRow(triangle[row-1])
        end
    end
    return [triangle[k] for k in 0:n]
end

# Pascal's triangle from Figure 3
getPascalTriangle(4)

function getNumLen(n::Int)::Int
    return n |> string |> length
end

function getMaxNumLen(v::Vec{Int})::Int
    return map(getNumLen, v) |> maximum
end

function center(sth::A, endLength::Int)::Str where A<:Union{Int, Str}
    s::Str = string(sth)
    len::Int = length(s)
    @assert endLength > 0 && len > 0 "both endLength and len must be > 0"
    @assert endLength >= len "endLength must be >= len"
    diff::Int = endLength - len
    leftSpaceLen::Int = div(diff, 2)
    rightSpaceLen::Int = diff - leftSpaceLen
    return " " ^ leftSpaceLen * s * " " ^ rightSpaceLen
end

function getFmtRow(
    row::Vec{A}, numLen::Int, rowLen::Int)::Str where A<:Union{Int, Str}
    fmt(num) = center(num, numLen)
    formattedRow::Str = join(map(fmt, row), " ")
    return center(formattedRow, rowLen)
end

function getFmtPascTriangle(n::Int, k::Int)::Str
    @assert n >= 0 && k >= 0 "n and k must be >= 0"
    @assert n <= 10 && k <= 10 "n and k must be <= 10"
    @assert n >= k "n must be >= k"
    triangle::Vec{Vec{Int}} = getPascalTriangle(n)
    lastRow::Vec{Int} = triangle[end]
    maxNumWidth::Int = getMaxNumLen(lastRow) + 1
    lastRowWidth::Int = (n+1) * maxNumWidth + n
    fmtRow(row) = getFmtRow(row, maxNumWidth, lastRowWidth)
    formattedTriangle::Str = join(map(fmtRow, triangle), "\n")
    indicators::Vec{Str} = fill(" ", n+1)
    indicators[k+1] = "∆"
    return formattedTriangle * "\n" * fmtRow(indicators)
end

println(getFmtPascTriangle(9, 5))
binomial.(9, 0:9) # compare with last row of the printout
