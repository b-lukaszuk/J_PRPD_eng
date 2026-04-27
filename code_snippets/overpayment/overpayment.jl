import CairoMakie as Cmk

const Str = String
const Vec = Vector

# the code is meant to serve as a programming exercise, not a financial advice
# all the calculations may be incorrect

struct Mortgage
    principal::Real
    interestPercYr::Real
    numMonths::Int

    Mortgage(p::Real, i::Real, n::Int) = (p < 1 || i < 0 || n < 12 || n > 480) ?
        error("incorrect field values") : new(p, i, n)
end

# mortgages from chapter: mortgage
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

# calculate c - money paid to the bank every month
function getInstallment(m::Mortgage)::Real
    p::Real = m.principal
    r::Real = m.interestPercYr / 100 / 12
    n::Int = m.numMonths
    if r == 0
        return p / n
    else
        numerator::Real = r * p * (1+r)^n
        denominator::Real = ((1 + r)^n) - 1
        return numerator / denominator
    end
end

# single month payment of mortgage
# (remainingPrincipal, pincipalPaid, interestPaid)
function payOffMortgage(
    m::Mortgage, curPrincipal::Real, installment::Real,
    overpayment::Real)::Tuple{Real, Real, Real}
    if curPrincipal <= 0.0
        return (curPrincipal, 0.0, 0.0)
    end
    interestDecimalMonth::Real = m.interestPercYr / 100 / 12
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

struct Summary
    principal
    interest
    months

    Summary(p::Real, i::Real, m::Int) = (p < 1 || i < 0 || m < 12 || m > 480) ?
        error("incorrect field values") : new(p, i, m)
end

# pay off mortgage fully, with overpayment
function payOffMortgage(
    m::Mortgage,
    overpayments::Dict{Int, <:Real})::Summary
    installment::Real = getInstallment(m) # monthly payment
    princLeft::Real = m.principal
    princPaid::Real = 0.0
    interPaid::Real = 0.0
    totalPrincPaid::Real = 0.0
    totalInterestPaid::Real = 0.0
    months::Int = 0
    for month in 1:m.numMonths
        if princLeft <= 0
            break
        end
        months += 1
        princLeft, princPaid, interPaid = payOffMortgage(
            m, princLeft, installment, get(overpayments, month, 0))
        totalPrincPaid += princPaid
        totalInterestPaid += interPaid
    end
    return Summary(totalPrincPaid, totalInterestPaid, months)
end

# pay off mortgage according to the schedule, no overpayment
function payOffMortgage(m::Mortgage)::Summary
    return payOffMortgage(m, Dict{Int, Real}())
end

# quick sanity check
payOffMortgage(mortgage1)

function getTotalCost(s::Summary)::Real
    return s.principal + s.interest
end

function getTotalCostDiff(m::Mortgage, overpayments::Dict{Int, <:Real})::Real
    s1::Summary = payOffMortgage(m)
    s2::Summary = payOffMortgage(m, overpayments)
    return getTotalCost(s1) - getTotalCost(s2)
end

# answer to question 1
getTotalCostDiff(mortgage1, Dict(i => 200 for i in 1:mortgage1.numMonths)) |> fmt
getTotalCostDiff(mortgage2, Dict(i => 200 for i in 1:mortgage2.numMonths)) |> fmt

# answer to question 2
getTotalCostDiff(mortgage1, Dict(i => 200 for i in 1:mortgage1.numMonths)) |> fmt
getTotalCostDiff(mortgage1, Dict(13 => 20_000)) |> fmt

# answer to out of pure curiosity case
customOverpayments = Dict(i => 200 for i in 1:mortgage1.numMonths)
customOverpayments[13] = 20_000
getTotalCostDiff(mortgage1, customOverpayments) |> fmt

# fn from chapter about compound interest
function getValue(principal::Real, avgPercentage::Real, years::Int)::Float64
    @assert years > 0 "years must be greater than 0"
    @assert principal > 0 "principal must be greater than 0"
    return principal * (1+avgPercentage/100)^years
end

# answer to question 3
(
    getTotalCostDiff(mortgage1, Dict(13 => 20_000)) |> fmt,
    getValue(20_000, 5, 19) - 20_000 |> fmt
)

function addPieChart!(s::Summary, interestPercYr::Real, installment::Real,
                      fig::Cmk.Figure, ax::Cmk.Axis, col::Int)::Nothing
    colors::Vec{Str} = ["coral1", "turquoise2", "white", "white", "white"]
    lebels::Vec{Str} = ["interest = $(fmt(s.interest))",
                        "principal = $(fmt(s.principal))",
                        "$(s.months) months, $(interestPercYr)% yearly",
                        "total cost = $(fmt(s.principal + s.interest))",
                        "monthly payment = $(fmt(installment))"]
    Cmk.pie!(ax, [s.interest, s.principal], color=colors[1:2],
             radius=4, inner_radius=2, strokecolor=:white, strokewidth=5)
    Cmk.hidedecorations!(ax)
    Cmk.hidespines!(ax)
    Cmk.Legend(fig[3, col],
               [Cmk.PolyElement(color=c) for c in colors],
               lebels, valign=:bottom, halign=:center, fontsize=60,
               framevisible=false)
    return nothing
end

function drawComparison(m::Mortgage,
                        overpayments::Dict{Int, <:Real})::Cmk.Figure
    s1::Summary = payOffMortgage(m)
    s2::Summary = payOffMortgage(m, overpayments)
    installment::Real = getInstallment(m)
    fig::Cmk.Figure = Cmk.Figure(fontsize=18)
    ax1::Cmk.Axis = Cmk.Axis(
        fig[1:2, 1],
        title="Mortgage simulation\nw/o overpayment(s)\n(may not be accurate)",
        limits=(-5, 5, -5, 5), aspect=1)
    ax2::Cmk.Axis = Cmk.Axis(
        fig[1:2, 2],
        title="Mortgage simulation\nwith overpayment(s)\n(may not be accurate)",
        limits=(-5, 5, -5, 5), aspect=1)
    Cmk.linkxaxes!(ax1, ax2)
    Cmk.linkyaxes!(ax1, ax2)
    addPieChart!(s1, m.interestPercYr, installment, fig, ax1, 1)
    addPieChart!(s2, m.interestPercYr, installment, fig, ax2, 2)
    return fig
end

# 1st figure in the chapter
drawComparison(mortgage1, Dict(i => 200 for i in 1:mortgage1.numMonths))
# 2nd figure in the chapter
drawComparison(mortgage2, Dict(i => 200 for i in 1:mortgage2.numMonths))
