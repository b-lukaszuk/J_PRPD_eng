import CairoMakie as Cmk
import Symbolics as Sym

const Flt = Float64

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

struct Sphere
    radius::Flt
    Sphere(r::Flt) = (r <= 0) ? error("radius must be > 0") : new(r)
end

function getVolume(s::Sphere)::Flt
    return (4 / 3) * pi * s.radius^3
end

function getSurfaceArea(s::Sphere)::Flt
    return 4 * pi * s.radius^2
end

referenceDroplet = Sphere(10.0)

# fraction - 4/3, p - π, r3 - r^3, v - volume
Sym.@variables fraction p r3 v
Sym.symbolic_linear_solve(fraction * p * r3 ~ v, r3) # may take a moment

# formula equivalent to the one returned by the solver above
function getSphere(volume::Flt)::Sphere
    # cbrt - fn that calculates cube root of a number
    radius::Flt = cbrt(volume / (4/3) / pi)
    return Sphere(radius)
end

nDroplets = [1, 4, 8, 12]
totalVolumes = repeat([getVolume(referenceDroplet)], length(nDroplets))
individualVolumes = totalVolumes ./ nDroplets
droplets = getSphere.(individualVolumes)
radii = map(droplet -> droplet.radius, droplets)
individualSurfaceAreas = getSurfaceArea.(droplets)
totalSurfaceAreas = individualSurfaceAreas .* nDroplets

round.(radii, digits=2) # check that radii of lipid droplets get smaller
round.(individualVolumes, digits=2) # check that individualVolumes of lipid droplets getSmaller
round.(totalSurfaceAreas, digits=2) # check the total surface area of lipid droplets

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
    text=map(r -> "single droplet radius = $(round(r, digits=2)) [μm]", radii),
    fontsize=12, align=(:center, :center)
);
Cmk.text!(ax, nDroplets, totalSurfaceAreas .- 250,
          text=map((v, n) -> "volume ($n droplet/s) = $(round(Int, v)) [μm³]",
                   totalVolumes, nDroplets),
    fontsize=12, align=(:center, :center)
);
fig
