import CairoMakie as Cmk
import Random as Rnd
import Statistics as St

const Flt = Float64
const Str = String
const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

function getBdaysAtParty(nPeople::Int)::Vec{Int}
    @assert 5 <= nPeople <= 365 "nPeople must be in range [5-365]"
    return Rnd.rand(1:365, nPeople)
end

function getCounts(v::Vector{T})::Dict{T,Int} where T
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

function nSameBdays(counts::Dict{Int, Int}, n::Int=2)::Bool
    @assert 2 <= n <= 365 "n must be in range [2-365]"
    return isnothing(findfirst((>=)(n), counts)) ? false : true
    # or
    # return !isnothing(findfirst((>=)(n), counts))
end

function anyMyBday(counts::Dict{Int, Int}, myBday::Int=1)::Bool
    @assert 1 <= myBday <= 365 "myBDay must be in range [1-365]"
    return haskey(counts, myBday)
end

# isEventFn(Dict{Int, Int}) -> Bool
function getProbSuccess(nPeople::Int, isEventFn::Function,
                        nSimulations::Int=100_000)::Flt
    @assert 5 <= nPeople <= 365 "nPeople must be in range [5-365]"
    @assert 1e4 <= nSimulations <= 1e6 "nSimulations not in range [1e4-1e6]"
    successes::Vec{Bool} = Vec{Bool}(undef, nSimulations)
    for i in 1:nSimulations
        peopleBdays = getBdaysAtParty(nPeople)
        counts = getCounts(peopleBdays)
        eventOccured = isEventFn(counts)
        successes[i] = eventOccured
    end
    return sum(successes)/nSimulations
end

# running a simulation may take a while
# reducing nSimulations will shorten the time but lower the precision of prob. estimation
Rnd.seed!(101)
peopleAtParty = 5:30
probsAnySameBdays = [getProbSuccess(n, nSameBdays) for n in peopleAtParty]
probsMyBday = [getProbSuccess(n, anyMyBday) for n in peopleAtParty]

probsMyBdayTheor = (1/365) .* peopleAtParty
(probsMyBday .- probsMyBdayTheor) .|> abs |> St.mean

# figure from the chapter
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1], limits=(0, 31, 0, 0.75),
              title="Birthday paradox",
              xlabel="Number of people at a party", ylabel="Probability");
lin1 = Cmk.lines!(ax, peopleAtParty, probsAnySameBdays, color=:blue);
lin2 = Cmk.lines!(ax, peopleAtParty, probsMyBday, color=:orange);
Cmk.axislegend(ax,
               [lin1, lin2],
               ["any 2 people same birthday", "same birthday as me"],
               position=:lt);
fig
