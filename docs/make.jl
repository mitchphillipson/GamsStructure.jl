using Documenter,GamsStructure



const _PAGES = [
    "Introduction" => ["index.md","elements.md","sets.md","parameters.md","universe.md"],
    #"Sets" => ["sets/regions.md","sets/products.md","sets/sectors.md","sets/final_demand.md","sets/value_added.md"],
    #"Mappings" => ["mappings/product_aggregation.md","mappings/sector_aggregation.md","mappings/g20_regions.md"],
]

makedocs(
    sitename="GamsStructure.jl",
    authors="WiNDC",
    #format = Documenter.HTML(
    #    # See https://github.com/JuliaDocs/Documenter.jl/issues/868
    #    prettyurls = get(ENV, "CI", nothing) == "true",
    #    analytics = "UA-44252521-1",
    #    collapselevel = 1,
    #    assets = ["assets/extra_styles.css"],
    #    sidebar_sitename = false,
    #),
    strict = true,
    pages = _PAGES
)


deploydocs(
    repo = "github.com/mitchphillipson/GamsStructure.jl",
    target = "build",
    branch = "gh-pages",
 #   versions = ["stable" => "v^", "v#.#" ],
)