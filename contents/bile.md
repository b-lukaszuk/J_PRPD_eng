# Bile {#sec:bile}

In this chapter I used the following libraries.

```jl
s2 = """
import CairoMakie as Cmk # external library
import Symbolics as Sym # external library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/bile)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:bile_problem}

There are different types of nutrients to be found in food, but they can be
roughly divided into: sugars (carbohydrates), proteins and fats (lipids). Your
liver produces [bile](https://en.wikipedia.org/wiki/Bile) that is stored in the
gallbladder and released to the duodenum (part of the small intestine). As far
as I remember my biology classes bile facilitates digestion by breaking large
lipid (fat) droplets into smaller ones. Thanks to that it increases the total
surface area in contact with digestive enzymes (lipases). So much for the
theory, but I always wondered if that is true.

Use Julia to demonstrate that the total surface area of a few small lipid
droplets is actually greater than the surface area of a one big droplet. Of
course, the big droplet and small droplets should contain the same volume of
lipids.

> **_Hint:_** You will have to assume the shape of a lipid droplet. If your math
> is rusty, then choose something simple, like a
> [cube](https://en.wikipedia.org/wiki/Cube). For instance, as a starting point
> you may think about the classical [Rubik's
> cube](https://en.wikipedia.org/wiki/Rubik%27s_Cube) and into how many pieces
> you could break it. Then continue by calculating the areas and volumes of the
> big cube and the small cubes.

## Solution {#sec:bile_solution}

To me the shape that resembles the droplet the most is
[sphere](https://en.wikipedia.org/wiki/Sphere). Luckily, it also got well
defined formulas for surface area and volume (see the link above). So this is
what we will use in our solution.

```jl
s = """
struct Sphere
    radius::Flt
    Sphere(r::Flt) = (r <= 0) ? error("radius must be > 0") : new(r)
end

# formula from Wikipedia
function getVolume(s::Sphere)::Flt
    return (4/3) * pi * s.radius^3
end

# formula from Wikipedia
function getSurfaceArea(s::Sphere)::Flt
    return 4 * pi * s.radius^2
end
"""
sc(s)
```

Now, let's define a big lipid droplet with a radius of, let's say, 10 [μm].

```jl
s = """
referenceDroplet = Sphere(10.0)
"""
sc(s)
```

In the next step we will split this big droplet into a few smaller ones of equal
sizes. Splitting the volume is easy, we just divide it by the number of
droplets. However, we need a way to determine the size (`radius`) of each small
droplet. Let's try to transform the formula for a sphere's volume and see if we
can get a radius from that.

$$ v = \frac{4}{3} * \pi * r^3 $$ {#eq:sphere1}

If a = b, then b = a, so we may swap the sides.

$$ \frac{4}{3} * \pi * r^3 = v $$ {#eq:sphere2}

The multiplication is commutative (the order does not matter), i.e. 2 * 3 * 4 is
the same as 4 * 3 * 2 or 2 * 4 * 3, therefore we can rearrange elements on the
left side of @eq:sphere2 to:

$$ R^3 * \frac{4}{3} * \pi = v $$ {#eq:sphere3}

Now, one by one we can move \*$\frac{4}{3}$ and \*$\pi$ to the right side of
@eq:sphere3. Of course, we change the mathematical operation to the opposite
(division instead of multiplication) and get:

$$ r^3 = v / \frac{4}{3} / \pi $$ {#eq:sphere4}

All that's left to do is to move exponentiation ($x^3$) to the right side of
@eq:sphere4 while changing it to the opposite mathematical operation
(cube root, i.e. $\sqrt[3]{x}$).

$$ r = \sqrt[3]{v / \frac{4}{3} / \pi} $$ {#eq:sphere5}

Now, you might wanted to quickly verify the solution using
`Symbolic.symbolic_linear_solve` we met in @sec:bat_and_ball_solution.
Unfortunately, we cannot use `r^3` (`r` to the 3rd power) as an argument (and
solve for `r`), since then it wouldn't be a linear equation (to be linear the
power must be equal to 1) required by `_linear_solve`. We could use other, more
complicated solver, but instead we will keep things simple and apply a little
trick:

```jl
s = """
import Symbolics as Sym

# fraction - 4/3, p - π, r3 - r^3, v - volume
Sym.@variables fraction p r3 v
Sym.symbolic_linear_solve(fraction * p * r3 ~ v, r3) # may take a moment
"""
sco(s)
```

So, instead of writing the formula as it is, we just named our variables
`fraction`, `p`, `r3` and `v`. Anyway, according to `Sym.symbolic_linear_solve`
$r^3 = v / (\frac{4}{3} * \pi)$, which is actually the same as @eq:sphere4 above
[since e.g. 18 / 2 / 3 == 18 / (2 * 3)]. Ergo, we may be fairly certain we
correctly solved @eq:sphere4 and therefore @eq:sphere5.

Once, we confirmed the validity of the formula in @eq:sphere5, all that's left to
do is to translate it into Julia code.

```jl
s = """
function getSphere(volume::Flt)::Sphere
    # cbrt - fn that calculates cube root of a number
    radius::Flt = cbrt(volume / (4/3) / pi)
    return Sphere(radius)
end
"""
sc(s)
```

> **_Note:_** If there were no function for $\sqrt[3]{x}$ you could easily
> define it yourself with: `getCbrt(x) = x^(1/3)` (here I used a [single
> expression
> function](https://en.wikibooks.org/wiki/Introducing_Julia/Functions#Single_expression_functions)
> for brevity) since $\sqrt[n]{x} = x^{1/n}$.

Once we got that figured out, we evaluate the total area of the droplets of
different size.

```jl
s = """
nDroplets = [1, 4, 8, 12]
totalVolumes = repeat([getVolume(referenceDroplet)], length(nDroplets))
individualVolumes = totalVolumes ./ nDroplets
droplets = getSphere.(individualVolumes)
radii = map(s -> s.radius, droplets)
individualSurfaceAreas = getSurfaceArea.(droplets)
totalSurfaceAreas = individualSurfaceAreas .* nDroplets
"""
sc(s)
```

This seemed like a breeze thanks to the [dot
operators](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_repetition.html#sec:julia_language_dot_functions).
We begin by defining the `nDroplets`, i.e. the number of droplets that we will
consider. Next, we divide their `totalVolumes` by their numbers (`nDroplets`) to
get a volume of an individual droplet (`individualVolumes`). Based on the
individual volumes we create the `droplets` with the appropriate radii
(`getSphere.(individualVolumes)`). We also extract the `radii` for future use
(the drawing function below). Now, we calculate `individualSurfaceAreas` of our
small droplets (`getSurfaceArea.(droplets)`) and then their
`totalSurfaceAreas`. We were able to achieve all that in only 7 lines of code.

Anyway, now, we can either examine the vectors (`totalSurfaceAreas`, `radii`,
`nDroplets`, `individualVolumes`) one by one, or do one better and present them
on a graph with e.g. CairoMakie (I'm not going to explain the code below, for
reference see [my previous book](https://b-lukaszuk.github.io/RJ_BS_eng/) or
[CairoMakie tutorial](https://docs.makie.org/stable/tutorials/getting-started)).

```
import CairoMakie as Cmk

fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1],
              title="Lipid droplet size vs. summaric surface area",
              xlabel="number of lipid droplets",
              ylabel="total surface area [μm²]", xticks=0:13);
Cmk.scatter!(ax, nDroplets, totalSurfaceAreas,
             markersize=radii .* 5, color="gold1");
Cmk.xlims!(ax, -3, 16);
Cmk.ylims!(ax, 800, 3000);
Cmk.text!(ax, nDroplets, totalSurfaceAreas .- 150,
    text=map(r -> "single droplet radius = $(round(r, digits=2)) [μm]",
             radii),
    fontsize=12, align=(:center, :center)
);
Cmk.text!(ax, nDroplets, totalSurfaceAreas .- 250,
          text=map((v, n) ->
              "volume ($n droplet/s) = $(round(Int, v)) [μm³]",
                   totalVolumes, nDroplets),
    fontsize=12, align=(:center, :center)
);
fig
```

Behold.

![Bile. Splitting a big lipid droplet into a few smaller ones and the effect it has on their total surface area.](./images/bile.png){#fig:bile}

So it turns out that what they taught me in the school all those years ago is
actually true. But only now I can finally see it. Nice.

> **_Note:_** The above was an example of a geometrical property called
> [surface-to-volume-ratio](https://en.wikipedia.org/wiki/Surface-area-to-volume_ratio)
> that applies to more than just the spheres and got implications in many fields
> of science.
