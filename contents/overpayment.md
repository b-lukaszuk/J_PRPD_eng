# Overpayment {#sec:overpayment}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/overpayment)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:overpayment_problem}

We finished the previous chapter (@sec:mortgage) with the discussion on a topic
of a mortgage. In general, banks allow their clients to overpay their mortgages,
which should be beneficial to the borrowers. So here is a task for you.

Write a computer program, that will estimate the savings you make by overpaying
a mortgage (assume the whole overpayment goes to pay off the principal and
reduces the number of installments).

Use the program to answer a few questions.

How much money can you expect to save in the case of `mortgage1` (\$200,000,
6.49%, 20 years) and `mortgage2` (\$200,000, 4.99%, 30 years) (see
@sec:mortgage_solution) if you overpay them regularly every month with \$200.

For `mortgage1` which one is more worth it: to overpay it every month with
\$200 or to overpay it only once, let's say in month 13, with \$20,000?

Which scenario would you expect to give you more profit (in nominal value): to
overpay `mortgage1` with \$20,000 in month 13, or to put this \$20,000 into a
bank deposit that pays 5% yearly for the 19 years (roughly the remaining
duration of the mortgage)? For simplicity, assume there is no inflation.

## Solution {#sec:overpayment_solution}

We begin this section (just like the previous two) with a warning. The following
is just a programming exercise and not a financial advice. The discussion and
all the calculations may be incorrect.

OK, now for the task. There's no need to (completely) reinvent the wheel so we
will use `Mortgage`, `fmt` and `getInstallment` that we developed earlier (see
@sec:mortgage_solution).  Just in case, be sure to also check the terminology we
defined there. Anyway, the first function we'll define in this chapter is
`payOffMortgage`

```jl
s = """
# single month payment of mortgage, returns
# (remainingPrincipal, pincipalPaid, interestPaid)
function payOffMortgage(
    mortgage::Mortgage, curPrincipal::Real, installment::Real,
    overpayment::Real)::Tuple{Real, Real, Real}
    interestDecimalMonth::Real = mortgage.interestPercYr / 100 / 12
    interestPaid::Real = curPrincipal * interestDecimalMonth
    principalPaid::Real = installment - interestPaid
    newPrincipal::Real = curPrincipal - principalPaid
    return (newPrincipal - overpayment,
            principalPaid + overpayment, interestPaid)
end
"""
sc(s)
```

The function accepts (among others) `curPrincipal`, `installment` and
`overpayment` and does a payment for a single month. To that end, first we
calculate the monthly interest rate as a decimal (`interestDecimalMonth`) and
use it to calculate the interest and principal paid this month (`interestPaid`
and `principalPaid`). Afterwards we calculate our new, lower principal
(`newPrincipal`). Finally, we return a tuple with 3 values: 1) the remaining
principal (after a month), 2) principal paid in a given month (from
`installment` and `overpayment`), and 3) interest paid (from `installment`). The
remaining principal is `newPrincipal - overpayment`. The principal that we paid
off this month is `principalPaid` and `overpayment`. The interest paid this
month is just `interestPaid`.

Right away we see a reason or two why our function is likely not to be accurate.
For once, we lack the rounding of money to 2 decimal points (as a bank would
do). Secondly, a bank may charge a fee (or some money named otherwise) for every
overpayment we make. Still, since all this section is just a programming
exercise and not a financial advice then we will not be bothered by that fact.

Nonetheless, we will improve our `payOffMortgage` a bit, by dealing with some
edge cases: 1) when `curPrincipal` is 0 or negative (`if curPrincipal <= 0.0`
below), 2) when `curPrincipal` is equal to or smaller than the principal paid in
installment (`if curPrincipal <= principalPaid` below), and 3) when the new
principal is smaller than the overpayment (`if newPrincipal <= overpayment`
below). Therefore, our `payOffMortgage` will look something like:

```jl
s = """
# single month payment of mortgage
# (remainingPrincipal, pincipalPaid, interestPaid)
function payOffMortgage(
    mortgage::Mortgage, curPrincipal::Real, installment::Real,
    overpayment::Real)::Tuple{Real, Real, Real}
    if curPrincipal <= 0.0
        return (curPrincipal, 0.0, 0.0)
    end
    interestDecimalMonth::Real = mortgage.interestPercYr / 100 / 12
    interestPaid::Real = curPrincipal * interestDecimalMonth
    principalPaid::Real = installment - interestPaid
    if curPrincipal <= principalPaid
        return (0.0, curPrincipal, interestPaid)
    end
    newPrincipal::Real = curPrincipal - principalPaid
    if newPrincipal <= overpayment
        return (0.0, newPrincipal + principalPaid, interestPaid)
    end
    return (newPrincipal - overpayment,
            principalPaid + overpayment, interestPaid)
end
"""
sc(s)
```

Once we can pay it off for a month, we can pay it off completely and summarize
it. First, summary:

```jl
s = """
struct Summary
    principal::Real
    interest::Real
    months::Int

    Summary(p::Real, i::Real, m::Int) = (
		p < 1 || i < 0 || m < 12 || m > 480) ?
        error("incorrect field values") : new(p, i, m)
end
"""
sc(s)
```

Now, for the complete mortgage pay off.

```jl
s = """
# pay off mortgage fully, with overpayment
function payOffMortgage(
    mortgage::Mortgage,
    overpayments::Dict{Int, <:Real})::Summary
    installment::Real = getInstallment(mortgage) # monthly payment
    princLeft::Real = mortgage.principal
    princPaid::Real = 0.0
    interPaid::Real = 0.0
    totalPrincPaid::Real = 0.0
    totalInterestPaid::Real = 0.0
    months::Int = 0
    for month in 1:mortgage.numMonths
        if princLeft <= 0
            break
        end
        months += 1
        princLeft, princPaid, interPaid = payOffMortgage(
            mortgage, princLeft, installment, get(overpayments, month, 0))
        totalPrincPaid += princPaid
        totalInterestPaid += interPaid
    end
    return Summary(totalPrincPaid, totalInterestPaid, months)
end

# pay off mortgage according to the schedule, no overpayment
function payOffMortgage(mortgage::Mortgage)::Summary
    return payOffMortgage(mortgage, Dict{Int, Real}())
end
"""
sc(s)
```

We begin, by defining a few variables. For instance, `princLeft` will hold
principal sill left to pay after a month, `princPaid` will contain the value of
principal paid off in a given month, `intrPaid` will store the interest paid to
a bank in a given month. The above will be used in the `for` loop and will
change month by month. Next, the variables that will be used in the `Summary`
struct returned by our function (`totalInterestPaid`, `totalInterestPaid`,
`months`). In the `for` loop we pay off the mortgage month by month. If there
is no principal to be paid off (`if princLeft <= 0`) we `break`
early. Otherwise, we update the number of `months`, `totalPrincPaid`, and
`totalInterestPaid`. Notice, that we obtain the over-payment for a month from
the `overpayments` dictionary, where the default over-payment (if the key
doesn't exist) is 0 (`get(overpayments, month, 0)`).

Let's do a quick sanity check. Previously (@sec:mortgage_solution), we said that
the regular payment off `mortgage1` (\$200,000 at 6.49% for 20 years) will
roughly yield the principal of \$200,000 and the interest of \$157,593. Let's
see if we get that.

```jl
s = """
payOffMortgage(mortgage1)
"""
sco(s)
```

OK, so finally we are ready to answer our questions.

How much money can we potentially save in the case of `mortgage1` (\$200,000,
6.49%, 20 years) (see @sec:mortgage_solution) overpaid regularly every month
with \$200.

```jl
s = """
function getTotalCost(s::Summary)::Real
    return s.principal + s.interest
end

function getTotalCostDiff(m::Mortgage,
	overpayments::Dict{Int, <:Real})::Real
    s1::Summary = payOffMortgage(m)
    s2::Summary = payOffMortgage(m, overpayments)
    return getTotalCost(s1) - getTotalCost(s2)
end
"""
sc(s)
```

And (here we use
[comprehensions](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_repetition.html#sec:julia_language_comprehensions)
with a dictionary):

```jl
s = """
getTotalCostDiff(mortgage1,
	Dict(i => 200 for i in 1:mortgage1.numMonths)) |> fmt
"""
sco(s)
```

Quite a penny (see also @fig:mortgageOverpayment1).

![Overpaying a mortgage (\$200,000, 6.49%, 20 years) with \$200 monthly (estimation may not be accurate).](./images/mortgageOverpayment1.png){#fig:mortgageOverpayment1}

And now let's overpay `mortgage2` (\$200,000, 4.99%, 30 years) with \$200
monthly.

```jl
s = """
getTotalCostDiff(mortgage2,
	Dict(i => 200 for i in 1:mortgage2.numMonths)) |> fmt
"""
sco(s)
```

The total savings appear to be even greater than for `mortgage1`, still the
total cost seems to be greater for the overpaid `mortgage2` (see
@fig:mortgageOverpayment1 and @fig:mortgageOverpayment2).

![Overpaying a mortgage (\$200,000, 4.99%, 30 years) with \$200 monthly (estimation may not be accurate).](./images/mortgageOverpayment2.png){#fig:mortgageOverpayment2}

OK, time for the next question.

For `mortgage1` which one is more worth it: to overpay it every month with \$200
or to overpay it only once, let's say in month 13, with \$20,000?

```jl
s = """
(
	getTotalCostDiff(mortgage1,
		Dict(i => 200 for i in 1:mortgage1.numMonths)) |> fmt,
	getTotalCostDiff(mortgage1, Dict(13 => 20_000)) |> fmt
)
"""
sco(s)
```

Interesting, the above output indicates that we would be able to save more, with
an early (month 13) over-payment of a vast sum of money (\$20,000, 10% of our
initial principal) than just by regularly overpaying the mortgage with small
sums of it (\$200, 0.1% of our initial principal).

Out of pure curiosity, let's see how much we could save when we combine the two
(we overpay \$200 every month, except for month 13, where we overpay \$20,000)

```jl
s = """
customOverpayments = Dict(i => 200 for i in 1:mortgage1.numMonths)
customOverpayments[13] = 20_000
getTotalCostDiff(mortgage1, customOverpayments) |> fmt
"""
sco(s)
```

And now, the final question. Which one is better: to overpay `mortgage1` with
\$20,000 in month 13, or to put this \$20,000 into a bank deposit that pays 5%
yearly for the 19 years (roughly the remaining duration of the mortgage)?

```jl
s = """
(
	getTotalCostDiff(mortgage1, Dict(13 => 20_000)) |> fmt,
	# fn from chapter about compund interest
	getValue(20_000, 5, 19) - 20_000 |> fmt
)
"""
sco(s)
```

So if the calculations were accurate in this scenario we would have saved (in
nominal money) \$40,972 in interests, whereas gained extra \$30,593 (to our
initial \$20,000) on the bank deposit (compare with
@sec:compound_interest_problem_a1). Advantage over-payment.
