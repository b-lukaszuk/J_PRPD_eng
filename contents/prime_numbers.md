# Prime Numbers {#sec:prime_numbers}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/prime_numbers)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:prime_numbers_problem}

A prime number is an integer greater than 1 that is divisible only by 1 and
itself. Prime numbers found practical applications, e.g. in cryptography.

In this task your job is to write a function that returns all prime numbers up
to a certain extent. You may use any computational method from [the Wikipedia's
page](https://en.wikipedia.org/wiki/Prime_number#Computational_methods).

## Solution {#sec:prime_numbers_solution}

### Trial Division

We begin by implementing [trial
division](https://en.wikipedia.org/wiki/Prime_number#Trial_division) algorithm.
The above is a 'brute force' approach, namely we divide our candidate number,
`n`, by a series of integers (remember, a prime number is an integer greater
than 1 that is divisible only by 1 and itself). The method has a small
improvement, i.e. the divisors are in the range from 2 up to $\sqrt{n}$.

```jl
s = """
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
"""
sc(s)
```

The function is pretty straightforward. The first two prime numbers are 2
and 3. Hence, the if `n < 4` block that uses a [ternary
expression](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_decision_making.html#sec:ternary_expression). Next,
per algorithm we establish the maximum value of the divisor (`upTo`). To that
end we calculate `sqrt(n)`, round it to up to the next whole number (`ceil`) and
convert it to integer (`Int`). Then, we test if the divisors in the range
`2:upTo` divide our number `n` evenly (`n % i == 0`), if so we `return false`
right away, otherwise the number is prime (`return true`).

With our `isPrime` ready, generating a sequence of primes is a breeze.

```jl
s = """
function getPrimesV1(upTo::Int)::Vec{Int}
    @assert upTo > 1 "upTo must be > 1"
    return filter(isPrime, 2:upTo)
end
"""
sc(s)
```

All we had to do was to `filter` out primes from the sequence of numbers within
the desired range `2:upTo`. Time for a simple test.

```jl
s = """
# prime numbers up to 100 from:
# https://en.wikipedia.org/wiki/List_of_prime_numbers
primesFromWiki = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31,
	37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

getPrimesV1(100) == primesFromWiki
"""
sco(s)
```

Works like a charm.

### Sieve of Eratosthenes

Next, we will implement [the sieve of Eratosthenes
algorithm](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes) that finds
primes by

> ... iteratively marking as composite (i.e., not prime) the multiples of each
> prime, starting with the first prime number, 2.

(see the Wikipedia's page from the link above).

Let's get down to it.

```jl
s = """
function getPrimesV2(upTo::Int)::Vec{Int}
    @assert upTo > 1 "upTo must be > 1"
    nums::Vec{Int} = 1:upTo |> collect
    isPrimeTests::Vec{Bool} = ones(Bool, upTo)
    isPrimeTests[1] = false # first prime is: 2
    for num in nums
        if isPrimeTests[num]
            # numMultiples - local variable visible only in for loop
            numMultiples = (num*2):num:upTo # multiples of num
            isPrimeTests[numMultiples] .= false
        end
    end
    return nums[isPrimeTests]
end
"""
sc(s)
```

This time we begin by defining two vectors `nums` which contains all the
examined integers from a given range and `isPrimeTests` that contains indication
of whether a number in `nums` is prime. Initially, all the numbers are
considered to be primes (`ones(Bool, upTo)`) except for 1 (`isPrimeTests[1] =
false`). Then, we examine every number (`num`) out of the candidates (`nums`).
If a number is prime (`if isPrimeTests[num]`) we set all its multiples
(`numMultiples`) as not primes (`false`) using broadcasting (`.`) with the
assignment (`=`) operator. Once finished we return only the candidates that
passed the test (`return nums[isPrimeTests]`) using boolean indexing of a
vector.

Time for a simple test.

```jl
s = """
getPrimesV2(100) == primesFromWiki
"""
sco(s)
```

The test passed. Before we close this chapter let's see if the two functions
give identical results.

```jl
s = """
getPrimesV1(1000) == getPrimesV2(1000)
"""
sco(s)
```

Yes, they do.
