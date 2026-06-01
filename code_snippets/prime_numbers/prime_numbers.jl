const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

###############################################################################
#                          version 1: trial division                          #
###############################################################################
# https://en.wikipedia.org/wiki/Prime_number#Trial_division
function isPrime(n::Int)::Bool
    if n < 4
        return n < 2 ? false : true
    end
    upTo::Int = sqrt(n) |> ceil |> Int
    for i in 2:upTo
        if n % i == 0
            return false
        end
    end
    return true
end

function getPrimesV1(upTo::Int)::Vec{Int}
    @assert upTo > 1 "upTo must be > 1"
    return filter(isPrime, 2:upTo)
end

# version 1. testing
# prime numbers up to 100 from:
# https://en.wikipedia.org/wiki/List_of_prime_numbers
primesFromWiki = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
                  31, 37, 41, 43, 47, 53, 59, 61, 67,
                  71, 73, 79, 83, 89, 97]
getPrimesV1(100) == primesFromWiki


###############################################################################
#                       version 2: sieve of Eratosthenes                      #
###############################################################################
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
function getPrimesV2(upTo::Int)::Vec{Int}
    @assert upTo > 1 "upTo must be > 1"
    nums::Vec{Int} = 1:upTo |> collect
    isPrimeTests::Vec{Bool} = ones(Bool, upTo)
    isPrimeTests[1] = false # first prime is: 2
    for num in nums
        if isPrimeTests[num]
            # numMultiples - local variable visible only in for loop
            numMultiples = (num*2):num:upTo
            isPrimeTests[numMultiples] .= false
        end
    end
    return nums[isPrimeTests]
end

# version 2. testing
getPrimesV2(100) == primesFromWiki

# comparing two versions
getPrimesV1(1000) == getPrimesV2(1000)
