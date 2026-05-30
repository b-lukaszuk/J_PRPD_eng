import BenchmarkTools as Bt

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Vec = Vector

# problem description section
function recSum(v::Vec{Int})::Int
    if isempty(v)
        return 0
    else
        return v[1] + recSum(v[2:end])
    end
end

recSum([1])
recSum([1, 2, 3])
1:100 |> collect |> recSum # Gauss said it should be 5050

# solution section
function recFactorial(n::Int)::Int
    @assert 0 <= n <= 20 "n must be in range [0-20]"
    if n == 0
        return 1
    else
        return n * recFactorial(n-1)
    end
end

# redefinition
function recFactorialV2(n::Int)::Int
    @assert 0 <= n <= 20 "n must be in range [0-20]"
    return n == 0 ? 1 : n * recFactorialV2(n-1)
end

# redefinition, tail recursion
function recFactorialV3(n::Int, acc::Int=1)::Int
    @assert 0 <= n <= 20 "n must be in range [0-20]"
    return n == 0 ? acc : recFactorialV3(n-1, n * acc)
end

(
    recFactorial(6),
    recFactorial(20),
    recFactorialV2(6),
    recFactorialV2(20),
    recFactorialV3(6),
    recFactorialV3(20)
)

function recFib(n::Int)::Int
    @assert 0 <= n <= 40 "n must be in range [0-40]"
    if n == 0
        return 0
    elseif n == 1
        return 1
    else
        return recFib(n - 2) + recFib(n - 1)
    end
end

# more performant definition
function recFib!(n::Int, lookup::Dict{Int, Int})::Int
    @assert 0 <= n <= 40 "n must be in range [0-40]"
    @assert(haskey(lookup, 0) && haskey(lookup, 1),
            "lookup must have base cases")
    if !haskey(lookup, n)
        lookup[n] = recFib!(n-2, lookup) + recFib!(n-1, lookup)
    end
    return lookup[n]
end

# benchmarks (may take some time)
Bt.@benchmark recFib(40)

# should run calculations during every sub-test
Bt.@benchmark recFib!(40, Dict(0 => 0, 1 => 1))

# should run calculations only once (during first sub-test)
fibs = Dict(0 => 0, 1 => 1)
Bt.@benchmark recFib!(40, $fibs)
