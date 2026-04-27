const Flt = Float64
const Str = String
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# numbers for testing our stem-and-leaf plot
# prime numbers below 100
stemLeafTest1 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
                41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
# example from the Construction section
stemLeafTest2 = [44, 46, 47, 49, 63, 64, 66, 68, 68, 72, 72, 75,
                76, 81, 84, 88, 106]
# another example from the Construction section
stemLeafTest3 = [-23.678758, -12.45, -3.4, 4.43, 5.5, 5.678,
                16.87, 24.7, 56.8]

function howManyChars(num::Int)::Int
    return num |> string |> length
end

function getMaxLengthOfNum(nums::Vec{Int})::Int
    maxLen::Int = map(howManyChars, nums) |> maximum
    return max(2, maxLen)
end

function getStemAndLeaf(num::Int, maxLenOfNum::Int)::Tuple{Str, Str}
    @assert maxLenOfNum > 1 "maxLenOfNum must be greater than 1"
    @assert(howManyChars(num) <= maxLenOfNum,
            "character count in num must be <= maxLenOfNum")
    numStr::Str = lpad(abs(num), maxLenOfNum, "0")
    stem::Str = numStr[1:end-1] |> string
    leaf::Str = numStr[end] |> string
    stem = parse(Int, stem) |> string #1
    stem = num < 0 ? "-" * stem : stem #2
    stem = lpad(stem, maxLenOfNum-1, " ") #3
    return (stem, leaf)
end

# returns Dict{stem, [leaves]}
function getLeafCounts(nums::Vec{Int}, maxLenOfNum::Int)::Dict{Str, Vec{Str}}
    @assert length(unique(nums)) > 1 "numbers musn't be the same"
    counts::Dict{Str, Vec{Str}} = Dict()
    for num in nums
        stem, leaf = getStemAndLeaf(num, maxLenOfNum) # for's local vars
        if haskey(counts, stem)
            counts[stem] = push!(counts[stem], leaf)
        else
            counts[stem] = [leaf]
        end
    end
    return counts
end

function getStemLeafRow(key::Str, leafCounts::Dict{Str, Vec{Str}})::Str
    row::Str = key * "|"
    if haskey(leafCounts, key)
        row *= sort(leafCounts[key]) |> join
    end
    return row * "\n"
end

function getStemLeafPlot(nums::Vec{Int})::Str
    maxLenOfNum::Int = getMaxLengthOfNum(nums)
    leafCounts::Dict{Str, Vec{Str}} = getLeafCounts(nums, maxLenOfNum)
    low::Int, high::Int = extrema(nums)
    testedStems::Dict{Str, Bool} = Dict()
    result::Str = ""
    for num in low:1:high
        stem, _ = getStemAndLeaf(num, maxLenOfNum)
        if haskey(testedStems, stem)
            continue
        end
        result *= getStemLeafRow(stem, leafCounts)
        testedStems[stem] = true
    end
    return result
end

# testing with ints
getStemLeafPlot(stemLeafTest1) |> print
getStemLeafPlot(stemLeafTest2) |> print

function getStemLeafPlot(nums::Vec{Flt})::Str
    ints::Vec{Int} = round.(Int, nums)
    return getStemLeafPlot(ints)
end

# testing with floats
getStemLeafPlot(stemLeafTest3) |> print

# more testing
-10:1:10 |> collect |> getStemLeafPlot |> print
# compare with Fig12 from: https://b-lukaszuk.github.io/RJ_BS_eng/compare_contin_data_one_samp_ttest.html
[504, 477, 484, 476, 519, 481, 453, 485, 487, 501] |> getStemLeafPlot |> print
