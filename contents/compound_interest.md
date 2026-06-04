# Compound Interest {#sec:compound_interest}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/compound_interest)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:compound_interest_problem}

There is this cartoon [Futurama](https://en.wikipedia.org/wiki/Futurama) that
tells a story of a guy named Fry. The character was accidentally frozen on
December 31, 1999 and wakes up back to life on December 31, 2999. In season 1
episode 6 Fry visits his old bank. The teller informs him that he had on his
account 93 cents in 1999. However, with an average yearly interest of 2.25% over
the period of a thousand years it gives $4.3 billion.

Read about [compound interest](https://en.wikipedia.org/wiki/Compound_interest)
and use Julia to answer a few questions.

### Question 1 {#sec:compound_interest_problem_q1}

Is Fry really a billionaire?

### Question 2 {#sec:compound_interest_problem_q2}

According to [this
page](https://pl.wikipedia.org/wiki/Inflacja_w_Polsce#Historia) (careful it's in
Polish) the inflation in Poland over the period 2020-2024 was: 3.4%, 5.1%,
14.4%, 11.4%, and 3.6%. If on December 31, 2019 my monthly salary was $10,000
(I wished) then how much I would have to earn in January 2025 to be able to buy
the same amount of goods like in 2019?

### Question 3 {#sec:compound_interest_problem_q3}

Imagine that on January 1, 2020 I opened a bank deposit for 5 years with a
yearly interest rate of 6%. Given the inflation rates from the question 2
(@sec:compound_interest_problem_q2) would I make any real profit on January 1,
2025?

### Question 4 {#sec:compound_interest_problem_q4}

Let's say that an average Polish male, aka Jan Kowalski, retires at the age of
65, while his life expectancy at birth is 75 years. Jan starts his first job at
the age of 20 and earns $3,000 a month. However, since he had heard that the
pension a person receives is equal to 50% of their last salary, he decided to
save $200 monthly (a bit less than 7% of his earnings). Once he retires he'll
take the missing 50% from the pile of money that he saved so that the quality of
his life will not change.

Assume that: 1) there is no inflation; 2) Jan's salary is constant throughout
his lifetime; 3) he pays $2,400 into his savings account at the beginning of
each year; 4) the account gives him 2% yearly. Tell roughly how long will the
money last on the retirement?

## Solution {#sec:compound_interest_solution}

Before we begin a warning. The following section: the discussion, calculations,
etc. may or may not be accurate and are only meant as a programming exercise,
not a financial advice.

As a prelude let's write a helper function that will nicely display the amount
of money we get and improve the readability of our results.

```jl
s = """
function getFormattedMoney(money::Real, sep::Char=',')::Str
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

The function may not be the most performant, but it was pretty easy to write. It
receives money as a [Real](https://docs.julialang.org/en/v1/base/numbers/)
number and sets apart every three digits with a separator (`sep`) of our choice.
Since in English a decimal separator is `.` (dot) and a thousand separator is
`,` (comma) then that's what we used here as our default
(`sep::Char=','`). Inside our formatter we round the number to integer
(`round(Int, money)`) and convert it to `string`. Next we traverse all the
digits (`for digit`) in the opposite direction (from right to left) thanks to
the `reverse(amount)`. Every third digit (`if counter == 3`) we place our `sep`
to the `result` and reset the counter (`counter = 0`). Besides, we prepend our
`digit` to the `result` (`digit * result`) and increase the counter (`counter
+= 1`). In the end we return the formatted number (`result * " USD"`).

> **_Note:_** For another way to format a number to currency see
> @sec:regex_problem_solution4.

Let's see how it works.

```jl
s = """
getFormattedMoney(12345.06)
"""
sco(s)
```

I think that twelve thousand three hundred and forty five is much easier to
process this way than in its alternative transcription form (`12345`). Still, be
aware of the rounding that takes place in it.

### Answer 1 {#sec:compound_interest_problem_a1}

Before we begin a quick refresher on percentages. As explained, e.g.
[here](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_probability_definition.html)
per definition a percentage is a hundredth part of the whole and can be
represented in a few equivalent forms, i.e.

- 0% = $\frac{0}{100}$ = 0/100 = 0.00 = 0,
- 5% = $\frac{5}{100}$ = 5/100 = 0.05,
- 20% = $\frac{20}{100}$ = 20/100 = 0.20 = 0.2,
- 75% = $\frac{75}{100}$ = 75/100 = 0.75,
- 100% = $\frac{100}{100}$ = 100/100 = 1.00 = 1,
- 105% = $\frac{105}{100}$ = 105/100 = 1.05,
- 110% = $\frac{110}{100}$ = 110/100 = 1.10 = 1.1, etc.

For calculations it is especially useful to use them as decimals, hence we will
often divide a percentage by one hundred. Now, let's say that I got $100 (this
initial sum of money is called the **principal**) on a deposit that pays 5%
interest yearly. That means that after one year I will get $105 or 105% of my
initial principal (the 5% of \$100 is \$5, and it is the interest we get for
giving our money to the bank). We can express this mathematically as
`$100 * 105% = $105` or to
make it easier to type with a calculator `100 * 1.05 = 105`. If the deposit
lasted two years then I would have to repeat the process one more time for year
number two, i.e. `$105 * 105% = $110.25` (105% of my new principal), also to be
expressed as `105 * 1.05 = 110.25`. Since as we said the `$105` is
actually `100 * 1.05` then we can rewrite it as `(100 * 1.05) * 1.05 = 110.25`.
For year number three we got
`$110.25 * 105% = $115.7625` or `110.25 * 1.05 = 115.7625` or
`((100 * 1.05) * 1.05) * 1.05 = 115.7625`. The parenthesis are there to signify
boundaries of mathematical operations for a previous year. We can get rid of
them to get: `100 * 1.05 * 1.05 * 1.05` (we multiply `1.05` by itself as many
times as there are years). Hence a pattern emerges:

$deposit\ value = \$100 * 1.05^{number\ of\ years}$

or more generally (remember about the order of mathematical operations):

$total\ value = initial\ principal * (1 + percentage/100)^{number\ of\ years}$

Let's put that into a Julia's function.

```jl
s = """
function getValue(principal::Real, avgPercentage::Real, years::Int)::Flt
    @assert years > 0 "years must be greater than 0"
    @assert principal > 0 "principal must be greater than 0"
    return principal * (1+avgPercentage/100)^years
end
"""
sc(s)
```

And test it on our previous example.

```jl
s = """
round.([getValue(100, 5, i) for i in 1:3], digits=4)
"""
sco(s)
```

Now we are ready to see if Fry is a billionaire.

```jl
s = """
# Futurama s1e6: 93 cents (\$0.93), 2.25%, 1_000 years
frysMoney = getValue(0.93, 2.25, 1_000)
frysMoney |> getFormattedMoney
"""
sco(s)
```

And indeed he is (four billion, two hundred eighty three million, etc.). Still,
before you head towards a cryogenic clinic to duplicate Fry's success be aware
of all the issues with
[cryonics](https://en.wikipedia.org/wiki/Cryonics#History) and that most of the
people/bodies frozen in 1960s' are not preserved today. Therefore, the profit
seems to be purely theoretical.

Anyway, as said the function could be used to estimate the nominal value that
you would get from your deposit (with a stable yearly interest rate). You could
also look at it from the other end and estimate how much you would have to earn
to cover up for an average inflation rate over a few years. Keep that in mind as
we go to the solution for Question 2 (see @sec:compound_interest_problem_q2).

### Answer 2 {#sec:compound_interest_problem_a2}

What about Question 2 (@sec:compound_interest_problem_q2). If on December 31,
2019 my monthly salary was $10,000 then how much I would have to earn in January
2025 to maintain my purchasing power given that the inflation rates for years
2020-2024 were equal: 3.4%, 5.1%, 14.4%, 11.4%, and 3.6%. To answer that we will
use the same reasoning as in the previous section
(@sec:compound_interest_problem_a1), but since the percentages differ from year
to year we will use a `for` loop to cover for that.

```jl
s = """
function getValue(principal::Real, percentages::Vec{<:Real})::Flt
    @assert principal > 0 "principal must be greater than 0"
    for p in percentages
        principal *= 1 + (p / 100)
    end
    return principal
end
"""
sc(s)
```

Second `getValue` method defined, time to put it into good use.

```jl
s = """
money2019 = 10_000 # Dec 31, 2019
inflPoland = [3.4, 5.1, 14.4, 11.4, 3.6] # yrs: 2020-2024
money2025infl = getValue(money2019, inflPoland) # Jan 1, 2025
(
    getFormattedMoney(money2019),
    getFormattedMoney(money2025infl)
)
"""
sco(s)
```

So I would need to earn roughly $14,348 to be able to buy the same amount of
goods in 2025 as I could with $10,000 in 2019. Not sure why, but that doesn't
put a smile on my face.

### Answer 3 {#sec:compound_interest_problem_a3}

Now, let's think was it worth a while to open a 5 years long bank deposit (6%
yearly interest rate) on January 1, 2020 given the inflation rates discussed in
the previous section (@sec:compound_interest_problem_a2). Would I make any real
profit on January 1, 2025?

In order to figure that out we need to counterbalance two factors. The increase
in the nominal value that we get due to the interest rate and a drop in the real
value of money due to the inflation rate. In other words, we might want to
calculate the real percentage change in money value given the two factors
combined. For that we should either implement a suitable formula obtained from a
reliable source or come up with the one ourselves. In order to learn we will try
the latter approach (no pain, no gain). Still, we may make a mistake so, take it
with a grain of salt.

Anyway, I think we will use proportions (I believe they taught me that in the
high school in chemistry, so bear with me, you can do it) and some simple
imaginable example. To make sure we are on the same page let's talk briefly
about the proportions.

Imagine that for $10 (`usd` below) we can buy 2 bread loafs (`bl` below). If so,
then how much bread can we buy for $5? That's easy, one bread loaf. You can
solve it with proportions like so:

$$10\ usd - 2\ bl$$ {#eq:prop1}

$$5\ usd - x\ bl$$ {#eq:prop2}

We set the same units on the same sides (left - right). Next, in order to get
$x$ we multiply the numbers on the diagonals: 5 * 2 goes to the numerator and 10
goes into denominator (since it got no pair on the diagonal it falls to the
bottom):

$x = \frac{5\ usd\ *\ 2\ bl}{10\ usd}$

Then we forward to our solution.

$x = \frac{5 * 2}{10} = \frac{10}{10} = 1$

This works because @eq:prop1 and @eq:prop2 could be rewritten as:

$\frac{10}{2} = \frac{5}{x}$

or

$\frac{2}{10} = \frac{x}{5}$

The above is basically just finding an equivalent fraction that we learned about
in our primary schools (how many 5ths is equal to $\frac{2}{10}$?). Still, I
like and remember the proportions example better.

With that under our belts let's follow with a simple example. Imagine that in
this year for $100 (`usd` below) we can buy 100 chocolate bars (`cb` below). Due
to the yearly inflation that is 2%, the same 100 chocolate bars will
cost $102 after a year. Luckily, thanks to the 5% yearly interest
rate we will have $105 in banknotes from our deposit. So how many
chocolate bars will we be able to buy after a year?

That's easy thanks to the proportions.

$$102\ usd - 100\ cb$$ {#eq:prop3}

$$105\ usd - x\ cb$$ {#eq:prop4}

Which gives us:

$x = \frac{105\ usd\ * 100\ cb}{102\ usd}$

and

$x = \frac{105 * 100}{102} = calculator\ does\ pip,\ pip,\ ...\ \approx 102.94$

Therefore, we can see that in this scenario the $105 in banknotes will allow us
to buy 102.94 chocolate bars (we think of it as a stable product that by itself
does not gain or loose value over time). Based on the chocolate bars we can
evaluate the real gain/loss of our nominal money to be:
`102.94 - 100 = 2.94 chocolate bar` or 2.94% (chocolate bars were just an
abstraction needed as a reference point, something that does not change its
value over time, hence a constant). When we put it all together (starting from
@eq:prop3) in a formula, we get (notice that the 100 below is a constant that we
referred to in the sentence before):

$$real\ percentage = \frac{105\ usd\ *\ 100}{102\ usd} - 100$$ {#eq:prop5}

Just like the chocolate bars also the dollars are a placeholder in our
example. We used them because the more material and concrete the objects are the
easier it is to think about them and manipulate them in our heads. Notice that
`105 usd` in @eq:prop5 and @eq:prop4 actually stands for percentage gain in
value (`100 + inflation rate`) of our money (the 105% that we used in our
explanation in the calculations in @sec:compound_interest_problem_a1). On the
other hand, `102 usd` in @eq:prop5 and @eq:prop3 is actually a placeholder for
percentage change in value due to the inflation (we divide by it, so we decrease
our gain in numerator by it). Therefore we can rewrite @eq:prop5 to:

$$real\ percentage = \frac{(100\ +\ interest\ rate) * 100}{100\ +\ inflation\ rate} - 100$$ {#eq:prop6}

Now let's put @eq:prop6 into a Julia's function.

```jl
s = """
function getRealPercChange(interestPerc::Real, inflPerc::Real)::Flt
    return ((100 + interestPerc) * 100) / (100 + inflPerc) - 100
end
"""
sc(s)
```

> **_Note:_** As a practical exercise you may further simplify the formula in
> @eq:prop6 using a pen and paper. Of course, if you think that's too much
> mathematics for one day, then don`t. Julia won't mind computing the result of
> @eq:prop6 for you. Anyway, instead of relying on my formula you should
> probably go with [real interest
> rate](https://en.wikipedia.org/wiki/Real_interest_rate) expressed by [Fisher
> equation](https://en.wikipedia.org/wiki/Fisher_equation) that was developed by
> a professional.

Now we can use it to write our final, third method, for `getValue`.

```jl
s = """
function getValue(principal::Real,
                  interestPercs::Vec{<:Real},
                  inflationPercs::Vec{<:Real})::Flt
    @assert principal > 0 "principal must be greater than 0"
    @assert(length(interestPercs) == length(inflationPercs),
            "interestPercs and inflationPercs must be of equal lenghts")
    for (intr, infl) in zip(interestPercs, inflationPercs)
        principal = getValue(principal, getRealPercChange(intr, infl), 1)
    end
    return principal
end
"""
sc(s)
```

We will use it to answer our question.

```jl
s = """
interestDeposit = 6 # yrs: 2020-2024
numYrs = length(inflPoland)
money2025deposit = getValue(money2019,
	interestDeposit, numYrs)
money2025depositInflation = getValue(
    money2019,
	repeat([interestDeposit], numYrs), inflPoland)


(
    getFormattedMoney(money2019), # Dec 31, 2019 or Jan 1, 2020
    getFormattedMoney(money2025deposit), # Jan 1, 2025
    getFormattedMoney(money2025depositInflation) # Jan 1, 2025
)
"""
sco(s)
```

And again, reality turns out to be disappointing. The initial principal of
$10,000 (January 1, 2020) was increased by 6% yearly which gave me $13,382 in
banknotes on January 1, 2025 for which I can buy the same amount of goods that I
could for $9,327 on January 1, 2020. So despite more money in my wallet
(nominal increase) I actually lost some real value. Eh.

OK, let's try to be optimistic here. The glass is half full. By putting the
money on the deposit (6% yearly) we lost some value. Still, if we left it on an
ordinary account with a lousy 0.5% interest rate the financial outcome would be
even more unsatisfactory.

```jl
s = """
(
	# nominal gain
	getFormattedMoney(
		getValue(money2019, 0.5, numYrs)),
	# real value
	getFormattedMoney(
		getValue(money2019, repeat([0.5], numYrs), inflPoland))
)
"""
sco(s)
```

So always look on the bright side of life, but look for something better and
think before you leap.

### Answer 4 {#sec:compound_interest_problem_a4}

Time for the last question.

Jan Kowalski saves $2,400 per year with constant 2% interest rate over his
working life. If so, then how much will he get in the end and for how long will
it last?

First, the savings.

```jl
s = """
function getRetirementSavings(moneyPerYr::Real, avgPercPerYr::Real,
                              years::Int)::Flt
    @assert moneyPerYr > 0 "moneyPerYr must be greater than 0"
    @assert avgPercPerYr > 0 "avgPercPerYr must be greater than 0"
    @assert 0 < years < 50 "years must be in range [1-49]"
    savings::Flt = 0.0
    multiplier::Flt = 1 + avgPercPerYr / 100
    for _ in 1:years
        savings += moneyPerYr # saving on Jan 1
        savings *= multiplier # interest paid on Dec 31
    end
    return savings
end
"""
sc(s)
```

After the previous sections, the function may seem ridiculously simple to
you. For each year (`for _ in 1:years`) we save some money (`savings +=
moneyPerYr`) of which we get our interest (`savings *= mulitplier`) based on the
formulas discussed in (@sec:compound_interest_problem_a1 and
@sec:compound_interest_problem_a2). Once we are done, we return what we saved.

```jl
s = """
savingsPerYr = 2_400 # or 200 * 12
savingsPercentageYr = 2
yrsWorking = 65 - 20

moneyPutAside = savingsPerYr * yrsWorking
savings = getRetirementSavings(
	savingsPerYr, savingsPercentageYr, yrsWorking)

(
	moneyPutAside |> getFormattedMoney,
	savings |> getFormattedMoney
)
"""
sco(s)
```

So over the period of 45 working years (`yrsWorking`) Jan Kowalski would have
put aside roughly $108,000 which together with interests should give him
$175,993.

Now, remember, that the idea is to take $1,500 from this pile of money every
month to fill the gap caused by his pension being equal to 50% of his final
salary (which we said was $3,000). So let's see for how long it would last.

```jl
s = """
# 1,500 usd a month, 12 months per year
round(savings / 1_500 / 12, digits=2)
"""
sco(s)
```

He should be able to maintain his standard of living for roughly 10 years, which
is his expected life expectancy on retirement (retires at 65, lives up to
75). So, I guess that if Jan intends to beat the average and spend more time on
the retirement, then he must save some more cash. The same seems to be true if
the pension is less than 50% of his last salary. Anyway, it appears that to have
some spare money for your retirement might be a prudent idea.
