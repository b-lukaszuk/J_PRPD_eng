const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# matrices are often named with a single capital letter
# convention from mathematics
A = [10.5 9.5; 8.5 7.5; 6.5 5.5]
A

# i'm not a mathematician though
# Math is Fun examples
a = [1 2 3; 4 5 6]
b = [7 8; 9 10; 11 12]

# Khan Academy examples
c = [-1 3 5; 5 5 2]
d = [3 4; 3 -2; 4 -2]

function getDotProduct(row::Vec{Int}, col::Vec{Int})
    @assert length(row) == length(col) "row & col must be of equal length"
    return map(*, row, col) |> sum
end

# alternative version of getDotProduct
function getDotProduct(row::Vec{Int}, col::Vec{Int})
    @assert length(row) == length(col) "row & col must be of equal length"
    return sum(row .* col)
end

function multiply(m1::Matrix{Int}, m2::Matrix{Int})::Matrix{Int}
    nRowsMat1, nColsMat1 = size(m1)
    nRowsMat2, nColsMat2 = size(m2)
    @assert  nColsMat1 == nRowsMat2 "the matrices are incompatible"
    result::Matrix{Int} = zeros(nRowsMat1, nColsMat2)
    for r in 1:nRowsMat1
        for c in 1:nColsMat2
            result[r, c] = getDotProduct(m1[r,:], m2[:, c])
        end
    end
    return result
end

# alternative version of multiply
function multiply(m1::Matrix{Int}, m2::Matrix{Int})::Matrix{Int}
    nRowsMat1, nColsMat1 = size(m1)
    nRowsMat2, nColsMat2 = size(m2)
    @assert  nColsMat1 == nRowsMat2 "the matrices are incompatible"
    result::Matrix{Int} = zeros(nRowsMat1, nColsMat2)
    for r in 1:nRowsMat1, c in 1:nColsMat2
        result[r, c] = getDotProduct(m1[r,:], m2[:, c])
    end
    return result
end

# visually testing the result of Math is Fun example
multiply(a, b)

# visually testing the result of Kahn Academy example
multiply(c, d)

# testing the result against the built in *
(a * b) == multiply(a, b)
(c * d) == multiply(c, d)
