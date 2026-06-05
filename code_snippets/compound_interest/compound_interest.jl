const Flt = Float64
const Str = String
const Vec = Vector

# WARNING
# the code is meant to serve as a programming exercise, not a financial advice
# all the calculations may be incorrect

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

getFormattedMoney(12345.06)
getFormattedMoney(12345.6) # be aware of rounding

# Question 1
function getValue(principal::Real, avgPercentage::Real, years::Int)::Flt
    @assert years > 0 "years must be greater than 0"
    @assert principal > 0 "principal must be greater than 0"
    return principal * (1+avgPercentage/100)^years
end

# Futurama s1e6: 93 cents ($0.93), 2.25%, 1_000 years
frysMoney = getValue(0.93, 2.25, 1_000)
frysMoney |> getFormattedMoney

# Question 2
function getValue(principal::Real, percentages::Vec{<:Real})::Flt
    @assert principal > 0 "principal must be greater than 0"
    for p in percentages
        principal *= 1 + (p / 100)
    end
    return principal
end

money2019 = 10_000 # Dec 31, 2019
inflPoland = [3.4, 5.1, 14.4, 11.4, 3.6] # yrs: 2020-2024
money2025infl = getValue(money2019, inflPoland) # Jan 1, 2025
(
    getFormattedMoney(money2019),
    getFormattedMoney(money2025infl)
)

# Question 3
function getRealPercChange(interestPerc::Real, inflPerc::Real)::Flt
    return ((100 + interestPerc) * 100) / (100 + inflPerc) - 100
end

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

interestDeposit = 6 # yrs: 2020-2024
numYrs = length(inflPoland)
money2025deposit = getValue(money2019, interestDeposit, numYrs)
money2025depositInflation = getValue(
    money2019, repeat([interestDeposit], numYrs), inflPoland)

(
    getFormattedMoney(money2019), # Dec 31, 2019
    getFormattedMoney(money2025deposit), # Jan 1, 2025
    getFormattedMoney(money2025depositInflation) # Jan 1, 2025
)

# an oridinary bank account, 0.5% interest rate
(
    # nominal gain
    getFormattedMoney(
        getValue(money2019, 0.5, numYrs)),
    # real value
    getFormattedMoney(
        getValue(money2019, repeat([0.5], numYrs), inflPoland))
)

# Question 4
function getRetirementSavings(moneyPerYr::Real, avgPercPerYr::Real,
                              years::Int)::Flt
    @assert moneyPerYr > 0 "moneyPerYr must be greater than 0"
    @assert avgPercPerYr > 0 "avgPercPerYr must be greater than 0"
    @assert 0 < years < 50 "years must be in range [1-49]"
    savings::Flt = 0.0
    multiplier::Flt = 1 + avgPercPerYr / 100
    for _ in 1:years
        savings += moneyPerYr
        savings *= multiplier
    end
    return savings
end

savingsPerYr = 2_400 # or 200 * 12
savingsPercentageYr = 2
yrsWorking = 65 - 20

moneyPutAside = savingsPerYr * yrsWorking
savings = getRetirementSavings(savingsPerYr, savingsPercentageYr, yrsWorking)

moneyPutAside |> getFormattedMoney
savings |> getFormattedMoney

# for how long it lasts on retirement
# 1,500 usd a month, 12 months per year
round(savings / 1_500 / 12, digits=2)
