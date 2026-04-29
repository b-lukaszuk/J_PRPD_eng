# Mortgage {#sec:mortgage}

In this chapter I used the following libraries.

```jl
s2 = """
import CairoMakie as Cmk # external library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/mortgage)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:mortgage_problem}

Sooner or later most of us ordinary folk end up taking a mortgage to buy an
apartment or a house.

So here are two scenarios for you:

1. you borrow $200,000 (principal) for 20 years at 6.49% (constant yearly interest rate)
2. you borrow $200,000 (principal) for 30 years at 4.99% (constant yearly interest rate)

Write a Julia program that will tell you:

1. How much money will you pay every month (installment) in both cases (assume
   fixed rate mortgage)?
2. How much principal you will still owe to the bank at year 15 in each
   case?
3. When will your debt be $\le$ $100'000?
4. Which of the two mortgages is more worth it for you (the smaller total cost
   and total interest you pay to the bank)?

Feel free to add some visual flair to your solution.

BTW. You may read about mortgages,
e.g. [here](https://en.wikipedia.org/wiki/Mortgage_calculator#).

## Solution {#sec:mortgage_solution}

Before we begin a few short definitions that we will use here (so that we are on
the same page).

- principal - the money you borrow form a bank
- interest - the money you pay extra (except for the money you borrowed)
- interest rate - a percentage of principal which you will pay as interest
- installment - fixed monthly payment to the bank in order to cover you debt,
  part of it goes to pay off the principal and part to pay off the interest

Next, let's use the formatting function from @sec:compound_interest_solution.

```jl
s = """
# getFormattedMoney from chapter: compound interest, modified
function fmt(money::Real, sep::Char=',',)::Str
    @assert money >= 0 "money must be >= 0"
    amount::Str = round(Int, money) |> string
    result::Str = ""
    counter::Int = 0
    for digit in reverse(amount) # digit is a single digit (type Char)
        if counter == 3
            result = sep * result
            counter = 0
        end
        result = digit * result
        counter += 1
    end
    return result * " USD"
end
"""
sc(s)
```

> **_Note:_** For another way to format a number to currency see
> @sec:regex_problem_solution4.

Time to define a `struct` that will contain the data necessary to perform
calculations for a given mortgage.

```jl
s = """
struct Mortgage
    principal::Real
    interestPercYr::Real
    numMonths::Int

    Mortgage(p::Real, i::Real, n::Int) = (
		p < 1 || i < 0 || n < 12 || n > 480) ?
		error("incorrect field values") : new(p, i, n)
end

mortgage1 = Mortgage(200_000, 6.49, 20*12)
mortgage2 = Mortgage(200_000, 4.99, 30*12)
"""
sc(s)
```

Finally, we are ready to calculate our monthly payment to the bank.

```jl
s = """
# calculate c - money paid to the bank every month
function getInstallment(m::Mortgage)::Flt
    p::Real = m.principal
    r::Real = m.interestPercYr / 100 / 12
    n::Int = m.numMonths
    if r == 0
        return p / n
    else
        numerator::Flt = r * p * (1+r)^n
        denominator::Flt = ((1 + r)^n) - 1
        return numerator / denominator
    end
end
"""
sc(s)
```

All the formulas are based on [this Wikipedia
page](https://en.wikipedia.org/wiki/Mortgage_calculator#). Notice that the
function's arguments (`Mortgage` fields in `getInstallment` and the arguments to
`getPrincipalAfterMonth` below) contain longer (more descriptive) names, whereas
inside the functions we use the abbreviations (case insensitive) found in the
above-mentioned formulas .

With that done, we can answer how much money we will have to pay to the bank
every month for the duration of our mortgage.

```jl
s = """
(
    getInstallment(mortgage1) |> fmt,
    getInstallment(mortgage2) |> fmt
)
"""
sco(s)
```

The money we still owe to the bank (principal) will change month after month
(because every month we pay off a fraction of it with our installment), so let's
calculate that.

```jl
s = """
# amount of money owed after every month
function getPrincipalAfterMonth(prevPrincipal::Real,
                                interestPercYr::Real,
                                installment::Flt)::Flt
    @assert((prevPrincipal >= 0 && interestPercYr >= 0 && installment > 0),
            "incorrect argument values")
    p::Real = prevPrincipal
    r::Real = interestPercYr / 100 / 12
    c::Flt = installment
    return (1 + r) * p - c
end
"""
sc(s)
```

Not much to explain here, just a simple rewrite of the formula into Julia's code
(first we increase the principal by interest, then we subtract the installment
from it). Now we can estimate the principal owed to the bank each year.

```jl
s = """
# paying off mortgage year by year
# returns principal still owed every year
function getPrincipalOwedEachYr(m::Mortgage)::Vec{Flt}
    monthlyPayment::Flt = getInstallment(m)
    curPrincipal::Real = m.principal
    principalStillOwedYrs::Vec{Flt} = [curPrincipal]
    for month in 1:m.numMonths
        curPrincipal = getPrincipalAfterMonth(
            curPrincipal, m.interestPercYr, monthlyPayment)
        if month % 12 == 0
            push!(principalStillOwedYrs, curPrincipal)
        end
    end
    return principalStillOwedYrs
end
"""
sc(s)
```

Here we calculate the principal owed after every month, and once a year (`month
% 12 == 0`) we push it to a vector tracking its yearly change
(`principalStillOwedYrs`). Let's see how it works, if we did it right then in
the end the principal should drop to zero (small rounding errors possible).

```jl
s = """
principals1 = getPrincipalOwedEachYr(mortgage1)
principals2 = getPrincipalOwedEachYr(mortgage2)

(
    principals1[end],
    principals2[end],
    round(principals1[end], digits=2),
    round(principals2[end], digits=2)
)
"""
sco(s)
```

So how much principal we still owe to the bank at the beginning of year 15 in
each scenario?

```jl
s = """
(
    principals1[15] |> fmt,
    principals2[15] |> fmt
)
"""
sco(s)
```

Hmm, quite a lot (remember we borrowed \$200,000 for 20 and 30 years). And when
will this value drop $\le$ 100,000 USD ($\le$ half of what we borrowed)?

```jl
s = """
(
    findfirst(p -> p <= 100_000, principals1),
    findfirst(p -> p <= 100_000, principals2)
)
"""
sco(s)
```

In general, for quite some time the money we pay to the bank mostly pay off the
interest and not the principal, so that it drops slowly at first (see
@fig:mortgagePrincipalsYrByYr).

![Principal still owed to the bank year by year. Mortgage: $200,000 at 6.49% yearly for 20 years. The estimation may not be accurate.](./images/mortgagePrincipalsYrByYr.png){#fig:mortgagePrincipalsYrByYr}

To answer the last question (which mortgage is more worth it for us in terms of
total payment and total interest) we'll use a [pie
chart](https://docs.makie.org/v0.21/reference/plots/pie).

```
import CairoMakie as Cmk

function addPieChart!(m::Mortgage, fig::Cmk.Figure,
                      ax::Cmk.Axis, col::Int)::Nothing
    installment::Flt = getInstallment(m)
    totalInterest::Flt = installment * m.numMonths - m.principal
    yrs::Flt = round.(m.numMonths / 12, digits=2)
    colors::Vec{Str} = ["coral1", "turquoise2", "white", "white", "white"]
    lebels::Vec{Str} = ["interest = $(fmt(totalInterest))",
                        "principal = $(fmt(m.principal))",
                        "$(yrs) years, $(m.interestPercYr)% yearly",
                        "total cost = $(fmt(installment * m.numMonths))",
                        "monthly payment = $(fmt(installment))"]
    Cmk.pie!(ax, [totalInterest, m.principal], color=colors[1:2],
             radius=4, strokecolor=:white, strokewidth=5)
    Cmk.hidedecorations!(ax)
    Cmk.hidespines!(ax)
    Cmk.Legend(fig[3, col],
               [Cmk.PolyElement(color=c) for c in colors],
               lebels, valign=:bottom, halign=:center, fontsize=60,
               framevisible=false)
    return nothing
end
```

The function is rather simple. It adds a pie chart to an existing figure and
axis. A point of notice, the colors used are
`["coral1", "turquoise2", "white", "white", "white"]`. The first two will be
used to paint the circle. But all of them, will be used in the legend
(`Cmk.Legend`). Hence, we used `"white"` for the values that are not in the
circle (white color on a white background in the legend is basically invisible).
We also used [string
interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation)
where a simple interpolated value is placed after the dollar character (`$`) or
in a more complicated case (a structure field, a calculation) it is put after
the dollar character and within parenthesis (e.g. `"$(2*3)"`).

Time to draw a comparison

```
function drawComparison(m1::Mortgage, m2::Mortgage)::Cmk.Figure
    fig::Cmk.Figure = Cmk.Figure(fontsize=18)
    ax1::Cmk.Axis = Cmk.Axis(
        fig[1:2, 1], title="Mortgage simulation\n(may not be accurate)",
        limits=(-5, 5, -5, 5), aspect=1)
    ax2::Cmk.Axis = Cmk.Axis(
        fig[1:2, 2], title="Mortgage simulation\n(may not be accurate)",
        limits=(-5, 5, -5, 5), aspect=1)
    Cmk.linkxaxes!(ax1, ax2)
    Cmk.linkyaxes!(ax1, ax2)
    addPieChart!(m1, fig, ax1, 1)
    addPieChart!(m2, fig, ax2, 2)
    return fig
end

drawComparison(mortgage1, mortgage2)
```

![Comparison of two mortgages (may not be accurate).](./images/mortgagesComparison.png){#fig:mortgageComparison}

So it turns out that despite the higher interest rate of 6.49% overall we will
pay less money to the bank for `mortgage1`. Therefore, if we are OK with the
greater monthly payment (installment) then we may choose that one.

Of course, all the above was just a programming exercise, not a financial
advice. Moreover, the simulation is likely to be inaccurate (to a various
extent) for many reasons. For instance, a bank may calculate the interest every
day, and not every month, in that case you will pay more. Compare with the
simple example below and the compound interest from
@sec:compound_interest_problem_a1.

```jl
s = """
# 6% yearly, after 1 year
(
	200_000 * (1 + 0.06) |> fmt, # capitalized yearly
	200_000 * (1 + (0.06/12))^12 |> fmt, # capitalized monthly
	200_000 * (1 + (0.06/365))^365 |> fmt, # capitalized daily
)
"""
sco(s)
```

Anyway, once you know what's going on, it should be easier to modify the program
to reflect a particular scenario more closely.
