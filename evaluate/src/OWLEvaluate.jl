module OWLEvaluate

using Plots, CSV, DataFrames, Statistics, JSON, StatsBase

basedir = joinpath(@__DIR__, "../results/repair")
mkpath(basedir)

const markers = Dict([:v1 => :circle, :v2 => :diamond, :shapley => :star6])
const marker_size = Dict([:v1 => 6, :v2 => 4, :shapley => 4])

function eval_correlation()
    repair = CSV.read("data/datasets.old/dataset1-0.5-99-3-30-repair.csv", DataFrame)
    p = plot(repair.repair_cost,
             repair.shapley_score,
             seriestype = :scatter,
             xlabel = "Repair cost",
             ylabel = "Shapley score",)

    @info corspearman(repair.repair_cost, repair.shapley_score)
end

function eval_depth_gap()
    repair1 = CSV.read("data/datasets/repair-v1-0.5.csv", DataFrame)
    repair2 = CSV.read("data/datasets/repair-v2-0.5.csv", DataFrame)
    shapley = CSV.read("data/datasets/shapley-v2-0.5.csv", DataFrame)
    repair1.depth_gap = repair1.max_depth .- repair1.depth
    repair2.depth_gap = repair2.max_depth .- repair2.depth
    shapley.depth_gap = shapley.max_depth .- shapley.depth

    p = plot(xlabel = "Deletion step",
             ylabel = "Relative Constraint Depth",
             show = false,)

    plot!(p,
          repair1.step,
          repair1.depth_gap,
          seriestype = :scatter,
          marker = markers[:v1],
          markersize = marker_size[:v1],
          label = "Repair strategy v1",)

    plot!(p,
          repair2.step,
          repair2.depth_gap,
          seriestype = :scatter,
          marker = markers[:v2],
          markersize = marker_size[:v2],
          label = "Repair strategy v2",)

    plot!(p,
          shapley.step,
          shapley.depth_gap,
          seriestype = :scatter,
          marker = markers[:shapley],
          markersize = marker_size[:shapley],
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "relative_depth_deletion_v1_v2_shapley.pdf"))
end

function eval_impact()
    repair1 = CSV.read("data/datasets/repair-v1-0.5.csv", DataFrame)
    repair2 = CSV.read("data/datasets/repair-v2-0.5.csv", DataFrame)
    shapley = CSV.read("data/datasets/shapley-v2-0.5.csv", DataFrame)

    p = plot(xlabel = "Deletion step",
             ylabel = "Hierarchy Impact",
             show = false,)

    plot!(p,
          repair1.step,
          repair1.impact,
          seriestype = :scatter,
          marker = markers[:v1],
          markersize = marker_size[:v1],
          label = "Repair strategy v1",)

    plot!(p,
          repair2.step,
          repair2.impact,
          seriestype = :scatter,
          marker = markers[:v2],
          markersize = marker_size[:v2],
          label = "Repair strategy v2",)

    plot!(p,
          shapley.step,
          shapley.impact,
          seriestype = :scatter,
          marker = markers[:shapley],
          markersize = marker_size[:shapley],
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "hierarchy_impact_v1_v2_shapley.pdf"))
end

function eval_deletion_count()
    repair1 = CSV.read("data/datasets/repair-v1-0.5.csv", DataFrame)
    repair2 = CSV.read("data/datasets/repair-v2-0.5.csv", DataFrame)
    shapley = CSV.read("data/datasets/shapley-v2-0.5.csv", DataFrame)

    p = plot(xlabel = "Deletion step",
             ylabel = "Violation score",
             show = false,)

    plot!(p,
          repair1.step,
          repair1.violation_score,
          seriestype = :steppost,
          label = "Repair strategy v1",)

    plot!(p,
          repair2.step,
          repair2.violation_score,
          seriestype = :steppost,
          label = "Repair strategy v2",)

    plot!(p,
          shapley.step,
          shapley.violation_score,
          seriestype = :steppost,
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "violation_score_step_v1_v2_shapley.pdf"))
end


function eval_repair_shapley(version::String)
    repair = CSV.read("data/datasets/repair-$version-0.5.csv", DataFrame)
    shapley = CSV.read("data/datasets/shapley-$version-0.5.csv", DataFrame)

    repair.violation_reduction = [missing; diff(-repair.violation_score)]
    shapley.violation_reduction = [missing; diff(-shapley.violation_score)]
    repair.depth_gap = repair.max_depth .- repair.depth
    shapley.depth_gap = shapley.max_depth .- shapley.depth

    p = plot(xlabel = "Deletion step",
             ylabel = "Violation score",
             show = false,)

    plot!(p,
          repair.step,
          repair.violation_score,
          seriestype = :steppost,
          label = "Repair strategy",)

    plot!(p,
          shapley.step,
          shapley.violation_score,
          seriestype = :steppost,
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "step_violation-$version.pdf"))


    p = plot(xlabel = "Deletion step",
             ylabel = "Depth gap",
             show = false,)

    plot!(p,
          repair.step,
          repair.depth_gap,
          seriestype = :scatter,
          label = "Repair strategy",)

    plot!(p,
          shapley.step,
          shapley.depth_gap,
          seriestype = :scatter,
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "depth_gap-$version.pdf"))

    p = plot(xlabel = "Deletion step",
             ylabel = "Violation reduction",
             show = false,)

    plot!(p,
          repair.step,
          repair.violation_reduction,
          seriestype = :scatter,
          label = "Repair strategy",)

    plot!(p,
          shapley.step,
          shapley.violation_reduction,
          seriestype = :scatter,
          label = "Shapley strategy",)

    savefig(p, joinpath(basedir, "violation_reduction-$version.pdf"))

    repair_average = sum(repair.violation_reduction[2:end]) / repair.step[end]
    shapley_average = sum(shapley.violation_reduction[2:end]) / shapley.step[end]
    open(joinpath(basedir, "metadata-$version.txt"), "w") do io
        println(io, "repair_average_violation_reduction = $repair_average")
        println(io, "shapley_average_violation_reduction = $shapley_average")
    end
end

function eval_repair_version()
    repair1 = CSV.read("data/datasets/repair-v1-0.5.csv", DataFrame)
    repair2 = CSV.read("data/datasets/repair-v2-0.5.csv", DataFrame)

    df = [repair1, repair2]

    for i in 1:2
        df[i].violation_reduction = [missing; diff(-df[i].violation_score)]
        df[i].depth_gap = df[i].max_depth .- df[i].depth
    end

    p = plot(xlabel = "Deletion step",
             ylabel = "Violation score",
             show = false,)

    for i in 1:2
        plot!(p,
              df[i].step,
              df[i].violation_score,
              seriestype = :steppost,
              label = "Repair strategy v$i",)
    end
    savefig(p, joinpath(basedir, "repair_step_violation.pdf"))

    
    p = plot(xlabel = "Deletion step",
             ylabel = "Depth gap",
             show = false,)

    for i in 1:2
        plot!(p,
              df[i].step,
              df[i].depth_gap,
              seriestype = :scatter,
              label = "Repair strategy v$i",)
    end
    savefig(p, joinpath(basedir, "repair_depth_gap.pdf"))

    p = plot(xlabel = "Deletion step",
             ylabel = "Violation reduction",
             show = false,)

    for i in 1:2
        plot!(p,
              df[i].step,
              df[i].violation_reduction,
              seriestype = :scatter,
              label = "Repair strategy v$i",)
    end
    savefig(p, joinpath(basedir, "repair_violation_reduction.pdf"))

    open(joinpath(basedir, "repair_metadata.txt"), "w") do io
        for i in 1:2
            repair_average = sum(df[i].violation_reduction[2:end]) / df[i].step[end]
            println(io, "repair_average_violation_reduction = $repair_average")
        end
    end
end


function evaluate()
    eval_repair_shapley("v1")
    eval_repair_shapley("v2")
end


end # module OWLEvaluate
