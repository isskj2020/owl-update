using Plots, CSV, DataFrames, Statistics, JSON, StatsBase

zscore(x) = (x .- mean(x)) ./ std(x)

const models = Dict([:qwen => "Qwen2.5 1.5B Instruct",
                     :llama => "Llama3.2 1B Instruct",
                     :gemma => "Gemma3 1B it",
                     :bge => "bge-large-en-v1.5",
                     :sbert => "paraphrase-multilingual-mpnet-base-v2",
                     :human => "Human",])
const colors = Dict([:qwen => :green,
                     :llama => :blue,
                     :gemma => :red,
                     :bge => :brown,
                     :sbert => :black,
                     :human => :cyan,])

rmse(x, y) = sqrt(mean((x .- y).^2))


basedir = joinpath(@__DIR__, "../results")

function eval_ml()
    eval_score()
    eval_priority()
    eval_processing_time()
end


function eval_priority()
    human = Vector{Float64}(JSON.parsefile("results/human/concepts-50.json"))
    bge_raw, bge_mean, bge_std = load_score("results/emb/bge/", 50)
    sbert_raw, sbert_mean, sbert_std = load_score("results/emb/sbert/", 50)
    gemma_raw, gemma_mean, gemma_std = load_score("results/llm/gemma/", 50)
    llama_raw, llama_mean, llama_std = load_score("results/llm/llama/", 50)
    qwen_raw, qwen_mean, qwen_std = load_score("results/llm/qwen/", 50)

    # Mean
    p = plot(
             xlabel = "Concept Pairs",
             ylabel = "Priority (Mean)",
             legend = :outerbottom,
             grid = true,)

    plot!(p, human, label = models[:human], color = colors[:human],      linewidth=4, alpha=1,)
    plot!(p, bge_mean, label = models[:bge], color = colors[:bge],       linewidth=1, alpha=0.7,)
    plot!(p, sbert_mean, label = models[:sbert], color = colors[:sbert], linewidth=1, alpha=0.7,)
    plot!(p, gemma_mean, label = models[:gemma], color = colors[:gemma], linewidth=2, alpha=0.7,)
    plot!(p, llama_mean, label = models[:llama], color = colors[:llama], linewidth=2, alpha=0.7,)
    plot!(p, qwen_mean, label = models[:qwen], color = colors[:qwen],    linewidth=2, alpha=0.7,)

    savefig(p, "results/priority_mean.pdf")

    # std
    p = plot(
             xlabel = "Concept Pairs",
             ylabel = "Priority (Standard Deviation)",
             legend = :outerbottom,
             grid = true,)

    plot!(p, bge_std, label = models[:bge], color = colors[:bge],       linewidth=1, alpha=1,)
    plot!(p, sbert_std, label = models[:sbert], color = colors[:sbert], linewidth=1, alpha=1,)
    plot!(p, gemma_std, label = models[:gemma], color = colors[:gemma], linewidth=2, alpha=1,)
    plot!(p, llama_std, label = models[:llama], color = colors[:llama], linewidth=2, alpha=1,)
    plot!(p, qwen_std, label = models[:qwen], color = colors[:qwen],    linewidth=2, alpha=1,)
    savefig(p, "results/priority_std.pdf")

    # z-score
    p = plot(
             xlabel = "Concept Pairs",
             ylabel = "Priority (Z-score)",
             legend = :outerbottom,
             grid = true,)

    plot!(p, zscore(human), label = models[:human], color = colors[:human],      linewidth=4, alpha=1,)
    plot!(p, zscore(bge_mean), label = models[:bge], color = colors[:bge],       linewidth=1, alpha=0.7,)
    plot!(p, zscore(sbert_mean), label = models[:sbert], color = colors[:sbert], linewidth=1, alpha=0.7,)
    plot!(p, zscore(gemma_mean), label = models[:gemma], color = colors[:gemma], linewidth=2, alpha=0.7,)
    plot!(p, zscore(llama_mean), label = models[:llama], color = colors[:llama], linewidth=2, alpha=0.7,)
    plot!(p, zscore(qwen_mean), label = models[:qwen], color = colors[:qwen],    linewidth=2, alpha=0.7,)

    savefig(p, "results/priority_z_score.pdf")
end

function eval_score()
    human = Vector{Float64}(JSON.parsefile("results/human/concepts-50.json"))
    human_z = zscore(human)

    size = 50
    bge_raw, bge_mean, bge_stds = load_score("results/emb/bge/", size)
    bge_z = zscore(bge_mean)
    sbert_raw, sbert_mean, sbert_stds = load_score("results/emb/sbert/", size)
    sbert_z = zscore(sbert_mean)
    gemma_raw, gemma_mean, gemma_stds = load_score("results/llm/gemma/", size)
    gemma_z = zscore(gemma_mean)
    llama_raw, llama_mean, llama_stds = load_score("results/llm/llama/", size)
    llama_z = zscore(llama_mean)
    qwen_raw, qwen_mean, qwen_stds = load_score("results/llm/qwen/", size)
    qwen_z = zscore(qwen_mean)

    savefig(scatter(bge_mean,
                    sbert_mean,
                    xlabel = models[:bge],
                    ylabel = models[:sbert],
                    label = false,), "results/score/bge_sbert_score.pdf")
    savefig(scatter(gemma_mean,
                    llama_mean,
                    xlabel = models[:gemma],
                    ylabel = models[:llama],
                    label = false,), "results/score/gemma_llama_score.pdf")
    savefig(scatter(llama_mean,
                    qwen_mean,
                    xlabel = models[:llama],
                    ylabel = models[:qwen],
                    label = false,), "results/score/llama_qwen_score.pdf")
    savefig(scatter(gemma_mean,
                    qwen_mean,
                    xlabel = models[:gemma],
                    ylabel = models[:qwen],
                    label = false,), "results/score/gemma_qwen_score.pdf")
    savefig(scatter(bge_mean,
                    gemma_mean,
                    xlabel = models[:bge],
                    ylabel = models[:gemma],
                    label = false,), "results/score/bge_gemma_score.pdf")
    savefig(scatter(bge_mean,
                    llama_mean,
                    xlabel = models[:bge],
                    ylabel = models[:llama],
                    label = false,), "results/score/bge_llama_score.pdf")
    savefig(scatter(bge_mean,
                    qwen_mean,
                    xlabel = models[:bge],
                    ylabel = models[:qwen],
                    label = false,), "results/score/bge_qwen_score.pdf")
    savefig(scatter(bge_mean,
                    human,
                    xlabel = models[:bge],
                    ylabel = models[:human],
                    label = false,), "results/score/bge_human_score.pdf")
    savefig(scatter(sbert_mean,
                    human,
                    xlabel = models[:sbert],
                    ylabel = models[:human],
                    label = false,), "results/score/sbert_human_score.pdf")
    savefig(scatter(qwen_mean,
                    human,
                    xlabel = models[:qwen],
                    ylabel = models[:human],
                    label = false,), "results/score/qwen_human_score.pdf")
    savefig(scatter(llama_mean,
                    human,
                    xlabel = models[:llama],
                    ylabel = models[:human],
                    label = false,), "results/score/llama_human_score.pdf")
    savefig(scatter(gemma_mean,
                    human,
                    xlabel = models[:gemma],
                    ylabel = models[:human],
                    label = false,), "results/score/gemma_human_score.pdf")

    cors_results = Dict(:bge   => corspearman(human_z, bge_z),
                        :sbert => corspearman(human_z, sbert_z),
                        :llama => corspearman(human_z, llama_z),
                        :gemma => corspearman(human_z, gemma_z),
                        :qwen  => corspearman(human_z, qwen_z),)
    rmse_results = Dict(:bge   => rmse(human_z, bge_z),
                        :sbert => rmse(human_z, sbert_z),
                        :llama => rmse(human_z, llama_z),
                        :gemma => rmse(human_z, gemma_z),
                        :qwen  => rmse(human_z, qwen_z),)

    open("results/score_metadata.txt", "w") do io
        println(io, "[corspearman z-score]")
        println(io, cors_results)
        println(io, "[rmse z-score]")
        println(io, rmse_results)
    end
    cors_results = Dict(:bge   => corspearman(human, bge_mean),
                        :sbert => corspearman(human, sbert_mean),
                        :llama => corspearman(human, llama_mean),
                        :gemma => corspearman(human, gemma_mean),
                        :qwen  => corspearman(human, qwen_mean),)
    rmse_results = Dict(:bge   => rmse(human, bge_mean),
                        :sbert => rmse(human, sbert_mean),
                        :llama => rmse(human, llama_mean),
                        :gemma => rmse(human, gemma_mean),
                        :qwen  => rmse(human, qwen_mean),)

    open("results/score_metadata.txt", "a") do io
        println(io, "[corspearman mean]")
        println(io, cors_results)
        println(io, "[rmse mean]")
        println(io, rmse_results)
    end
end

function eval_processing_time()
    xlabel = "Number of concept pairs"
    ylabel = "Processing time (s)"
    summary = summary_processing_time("results/emb/bge/results.csv")
    p = plot(summary.concept_size,
             summary.mean,
             yerror = summary.std,
             color = colors[:bge],
             markercolor = colors[:bge],
             markerstrokecolor = colors[:bge],
             marker = :circle,
             xlabel = xlabel,
             ylabel = ylabel,
             label = models[:bge],)

    summary = summary_processing_time("results/emb/sbert/results.csv")
    p = plot!(summary.concept_size,
              summary.mean,
              yerror = summary.std,
              color = colors[:sbert],
              markercolor = colors[:sbert],
              markerstrokecolor = colors[:sbert],
              marker = :circle,
              xlabel = xlabel,
              ylabel = ylabel,
              label = models[:sbert],)

    summary = summary_processing_time("results/llm/gemma/results.csv")
    p = plot!(summary.concept_size,
              summary.mean,
              yerror = summary.std,
              color = colors[:gemma],
              markercolor = colors[:gemma],
              markerstrokecolor = colors[:gemma],
              marker = :circle,
              xlabel = xlabel,
              ylabel = ylabel,
              label = models[:gemma],)

    summary = summary_processing_time("results/llm/llama/results.csv")
    p = plot!(summary.concept_size,
              summary.mean,
              yerror = summary.std,
              color = colors[:llama],
              markercolor = colors[:llama],
              markerstrokecolor = colors[:llama],
              marker = :circle,
              xlabel = xlabel,
              ylabel = ylabel,
              label = models[:llama],)

    summary = summary_processing_time("results/llm/qwen/results.csv")
    p = plot!(summary.concept_size,
              summary.mean,
              yerror = summary.std,
              color = colors[:qwen],
              markercolor = colors[:qwen],
              markerstrokecolor = colors[:qwen],
              marker = :circle,
              xlabel = xlabel,
              ylabel = ylabel,
              label = models[:qwen],)

    savefig(p, "results/processing-time.pdf")
end


function summary_processing_time(filepath::String)
    df = CSV.read(filepath, DataFrame)
    summary = combine(groupby(df, :concept_size),
                      :time => mean => :mean,
                      :time => std => :std)

    return summary
end

function load_score(dir::String, size::Int)
    scores = []
    for run in 1:5
        data = JSON.parsefile(joinpath(dir, "concepts-$size-$run.json"))
        push!(scores, data)
    end
    means = mean(scores)
    stds = std(scores)
    return scores, means, stds
end

