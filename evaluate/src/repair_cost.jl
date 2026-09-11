using Plots, CSV, DataFrames


basedir = joinpath(@__DIR__, "../results")

function eval_embedding()
    results = CSV.read("results/embedding.csv", DataFrame)
    return results
end

