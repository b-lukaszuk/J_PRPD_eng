import Dates as Dt
import Statistics as St

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Flt = Float64
const Vec = Vector

# https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
# global variables: a, c, m, seed
a = 1664525
c = 1013904223
m = 2^32
seed = round(Int, Dt.now() |> Dt.datetime2unix)

function setSeed!(newSeed)::Nothing
    global seed = newSeed
    return nothing
end

# https://en.wikipedia.org/wiki/Linear_congruential_generator
function getRandFromLCG()::Int
    newSeed::Int = (a * seed + c) % m
    setSeed!(newSeed)
    return newSeed
end

[getRandFromLCG() for _ in 1:6]

# rand in range [0-1)
function getRand()::Flt
    return getRandFromLCG() / m
end

[getRand() for _ in 1:3]

# rand in range [0-upToExcl)
function getRand(upToExcl::Int)::Int
    @assert 0 < upToExcl "uptoExcl must be greater than 0"
    return floor(getRand() * upToExcl)
end

function getCounts(v::Vec{T})::Dict{T,Int} where T
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

# tests for uniform distribution
setSeed!(1111) # for reproducibility
[getRand(3) for _ in 1:100_000] |> getCounts

setSeed!(1111) # for reproducibility
[getRand(5) for _ in 1:100_000] |> getCounts

# rand in range [minIncl-maxIncl]
function getRand(minIncl::Int, maxIncl::Int)::Int
    @assert 0 < minIncl < maxIncl "must get: 0 < minIncl < maxIncl"
    return minIncl + getRand(maxIncl-minIncl+1)
end

function getRand(n::Int, minIncl::Int, maxIncl::Int)::Vec{Int}
    @assert 0 < n "n must be greater than 0"
    return [getRand(minIncl, maxIncl) for _ in 1:n]
end

# tests for uniform distribution
setSeed!(2222)
getRand(100_000, 1, 4) |> getCounts

setSeed!(2222)
getRand(100_000, 3, 7) |> getCounts

# https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
function getRandn()::Tuple{Flt, Flt}
    theta::Flt = 2 * pi * getRand()
    R::Flt = sqrt(-2 * log(getRand()))
    x::Flt = R * cos(theta)
    y::Flt = R * sin(theta)
    return (x, y)
end

# general flattener, not just for floats (like in the chapter)
function flatten(v::Vec{Tuple{A, A}})::Vec{A} where A
    len::Int = length(v) * 2
    result::Vec{A} = Vec{A}(undef, len)
    i::Int = 1
    for (a, b) in v
        result[i] = a
        result[i+1] = b
        i += 2
    end
    return result
end

function getRandn(n::Int)::Vec{Flt}
    @assert n > 0 "n must be greater than 0"
    roughlyHalf::Int = cld(n, 2)
    return flatten([getRandn() for _ in 1:roughlyHalf])[1:n]
end

# test: mean ≈ 0.0, std ≈ 1.0
setSeed!(401)
x = getRandn(100)

St.mean(x), St.std(x)

function getRandn(n::Int, mean::Flt, std::Flt)::Vec{Flt}
    return mean .+ std .* getRandn(n)
end

# test, mean ≈ 100.0, std ≈ 16.0
setSeed!(401)
x = getRandn(100, 100.0, 16.0)

St.mean(x), St.std(x)
