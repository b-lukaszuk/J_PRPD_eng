import CairoMakie as Cmk

const Flt = Float64
const Str = String
const Vec = Vector

# WARNING
# the code is meant to serve as a programming exercise, not a financial advice
# all the calculations may be incorrect

struct Mortgage
    principal::Real
    interestPercYr::Real
    numMonths::Int

    Mortgage(p::Real, i::Real, n::Int) = (p < 1 || i < 0 || n < 12 || n > 480) ?
        error("incorrect field values") : new(p, i, n)
end

mortgage1 = Mortgage(200_000, 6.49, 20*12)
mortgage2 = Mortgage(200_000, 4.99, 30*12)

# getFormattedMoney from ../compound_interest/, modified
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

# formulas based on: https://en.wikipedia.org/wiki/Mortgage_calculator

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

(
    getInstallment(mortgage1) |> fmt,
    getInstallment(mortgage2) |> fmt
)

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

# principal should be lower than prevPrincipal
getPrincipalAfterMonth(200_000, 6.49, getInstallment(mortgage1)) |> fmt

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

principals1 = getPrincipalOwedEachYr(mortgage1)
principals2 = getPrincipalOwedEachYr(mortgage2)

(
    principals1[end],
    principals2[end],
    round(principals1[end], digits=2),
    round(principals2[end], digits=2)
)

# money still owed at the beginning of year 15
(
    principals1[15] |> fmt,
    principals2[15] |> fmt
)

# when we owe <= 100_000
(
    findfirst(p -> p <= 100_000, principals1),
    findfirst(p -> p <= 100_000, principals2)
)
# alternative to the above
(
    findfirst((<=)(100_000), principals1),
    findfirst((<=)(100_000), principals2)
)

function drawPrincipalOwedEachYr(m::Mortgage)::Cmk.Figure
    moneyStillInDebtYr::Vec{Flt} = getPrincipalOwedEachYr(m)
    xs::Vec{Int} = eachindex(moneyStillInDebtYr) |> collect
    ys::Vec{Flt} = LinRange(0, maximum(moneyStillInDebtYr), 5)
    fig::Cmk.Figure = Cmk.Figure(size=(1200, 600), fontsize=16)
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1:2],
                   title="Mortgage simulation (may not be accurate)",
                   subtitle= "$(fmt(m.principal)) at $(m.interestPercYr)% yearly",
                   xlabel="year of payment", ylabel="money owed to a bank",
                   xticks=xs, yticks=(ys, fmt.(ys)))
    Cmk.barplot!(ax, xs, moneyStillInDebtYr, color=:red,
                      label="unpaid principal")
    Cmk.axislegend(ax, position=:rt)
    return fig
end

drawPrincipalOwedEachYr(mortgage1) # first figure in the chapter
drawPrincipalOwedEachYr(mortgage2)

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

# 6% yearly, after 1 year
(
    200_000 * (1 + 0.06) |> fmt, # capitalized yearly
    200_000 * (1 + (0.06/12))^12 |> fmt, # capitalized monthly
    200_000 * (1 + (0.06/365))^365 |> fmt, # capitalized daily
)
