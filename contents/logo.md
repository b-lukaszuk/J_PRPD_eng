# Logo {#sec:logo}

In this chapter I used the following libraries.

```jl
s2 = """
import CairoMakie as Cmk # external library
import Random as Rnd # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/logo)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:logo_problem}

Julia is a nice programming language with over 10'000 registered packages for
community use. Some of them come with cool logos.

In this task your job is to use your favorite plotting library to reproduce the
logo of [JuliaStats](https://juliastats.org/) that you may find
[here](https://juliastats.org/images/logo.png) (it doesn't have to be exact).

## Solution {#sec:logo_solution}

The logo is composed of three disks build of points (scatter-plot) of three
colors: red, green and purple. So let's start small and try to replicate it by
placing the points (only three for now) on a graph in their correct locations.

```jl
s = """
import CairoMakie as Cmk

function drawLogo()::Cmk.Figure
    centersXs::Vec{Flt} = [1, 5.5, 10]
    centersYs::Vec{Flt} = [1, 6, 1]
    colors::Vec{Str} = ["red", "green", "purple"]
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1])
    Cmk.scatter!(ax, centersXs, centersYs, color=colors, markersize=50)
    return fig
end
"""
sc(s)
```

> **_Note:_** `CairoMakie` uses `Colors.jl`, the list of available color names
> is to be found
> [here](https://juliagraphics.github.io/Colors.jl/stable/namedcolors/).

The function is pretty simple. First, we defined the locations (based on a guess
and subsequent try and error) of the points with respect to the x- (`centersXs`)
and y-axis (`centersYs`), as well as their colors. Next we added the points
(`scatter!`) to the axis object (`ax`) attached to the figure object (`fig`).

Time to take a look.

```
drawLogo()
```

![Replicating JuliaStats logo. Attempt 1.](./images/logo1.png){#fig:logo1}

So far, so good. Now instead of a one big point we will need a few thousand
smaller points (let's say `markersize=10`) concentrated around the center of a
given group. Moreover, the points should be partially transparent [to that end
we will use `alpha` keyword argument (`alpha=0` - fully transparent, `alpha=1` -
fully opaque)]. One more thing, the points need to be randomly scattered, but
with a greater density closer to the group's center. This last issue will be
solved by obtaining random numbers from [the normal
distribution](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_normal_distribution.html)
with the mean equal 0 and the standard deviation equal 1. This is what `randn`
function will do. Thanks to this roughly 68% of the numbers will be in the
range -1 to 1, 95% in the range -2 to 2, and 99.7% in the range -3 to 3 (greater
density around the mean). Behold.

```jl
s1 = """
import Random as Rnd

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
"""
sc(s1)
```

Let's test it.

```
Rnd.seed!(303) # needed to make it reproducible
drawLogo()
```

![Replicating JuliaStats logo. Attempt 2.](./images/logo2.png){#fig:logo2}

We're almost there. Notice, that `CairoMakie` nicely centered the plot, so we
don't need to do this ourselves manually.

Anyway, all that's left to do is to remove the unnecessary elements from the
picture. A brief look into the documentation of the package indicates that
[hidedecorations and
hidespines](https://docs.makie.org/v0.21/reference/blocks/axis#Hiding-Axis-spines-and-decorations)
should do the trick.

```jl
s2 = """
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
"""
sc(s2)
```

And voila.

```
Rnd.seed!(303) # needed to make it reproducible
drawLogo()
```

![Replicating JuliaStats logo. Attempt 3.](./images/logo3.png){#fig:logo3}

We obtained a decent replica of the original. Of course, kudos go to the authors
of the original image for their creativity and artistic taste.
