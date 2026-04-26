import Test

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# the Gregorian Calendar was introduced in 1582
# that year: 4th October, was followed by 15th October
# before there was the Julian calendar
function isLeap(yr::Int)::Bool
    @assert 0 < yr < 4001 "yr must be in range [1-4000]"
    divisibleBy4::Bool = yr % 4 == 0
    gregorianException::Bool = (yr % 100 == 0) && (yr % 400 != 0)
    return divisibleBy4 && !gregorianException
end

# in the Gregorian calendar in every 400 years time span
# there are 303 regular years and 97 leap years
# very simplistic unit testing
function runTestSet()::Int
    startYr::Int = 0
    endYr::Int = 0
    numLeapYrs::Int = 0
    for i in 1:3601
        startYr = i
        endYr = i + 400 - 1
        numLeapYrs = filter(isLeap, startYr:endYr) |> length
        if numLeapYrs != 97
            return 1
        end
    end
    return 0 # C-like return value
end

runTestSet()

# slightly more correct testing
# but not quite, see: https://discourse.julialang.org/t/best-practices-for-julia-unit-testing/30858
Test.@testset "97 leap years per 400-year period" begin
    startYr::Int = 0
    endYr::Int = 0
    numLeapYrs::Int = 0
    for i in 1:3601
        startYr = i
        endYr = i + 400 - 1
        numLeapYrs = filter(isLeap, startYr:endYr) |> length
        Test.@test numLeapYrs == 97
    end
end
