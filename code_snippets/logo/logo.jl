# task: replicate JuliaStats logo as seen here
# https://juliastats.org/images/logo.png
import CairoMakie as Cmk
import Random as Rnd

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Flt = Float64
const Str = String
const Vec = Vector

# attempt 1
function drawLogo()::Cmk.Figure
    centersXs::Vec{Flt} = [1, 5.5, 10]
    centersYs::Vec{Flt} = [1, 6, 1]
    colors::Vec{Str} = ["red", "green", "purple"]
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1])
    Cmk.scatter!(ax, centersXs, centersYs, color=colors, markersize=50)
    return fig
end

drawLogo()

# attempt 2
function drawLogo()::Cmk.Figure
    centersXs::Vec{Flt} = [1, 5.5, 10]
    centersYs::Vec{Flt} = [1, 6, 1]
    colors::Vec{Str} = ["red", "green", "purple"]
    numOfPoints::Int = 3000
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1])
    for i in eachindex(colors)
        Cmk.scatter!(ax,
                     centersXs[i] .+ Rnd.randn(numOfPoints),
                     centersYs[i] .+ Rnd.randn(numOfPoints),
                     color=colors[i], markersize=10, alpha=0.25)
    end
    return fig
end

Rnd.seed!(303)
drawLogo()

# attempt 3
function drawLogo()::Cmk.Figure
    centersXs::Vec{Flt} = [1, 5.5, 10]
    centersYs::Vec{Flt} = [1, 6, 1]
    colors::Vec{Str} = ["red", "green", "purple"]
    numOfPoints::Int = 3000
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1])
    Cmk.hidedecorations!(ax)
    Cmk.hidespines!(ax)
    for i in eachindex(colors)
        Cmk.scatter!(ax,
                     centersXs[i] .+ Rnd.randn(numOfPoints),
                     centersYs[i] .+ Rnd.randn(numOfPoints),
                     color=colors[i], markersize=10, alpha=0.25)
    end
    return fig
end

Rnd.seed!(303)
drawLogo()
