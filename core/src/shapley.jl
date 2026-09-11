using Base.Threads

@kwdef mutable struct ShapleyContext <: OWLContext
    axioms::OWLAxioms
    samples::Int = 1000
end

@kwdef struct ShapleyResult
    id::String = DEFAULT_ID()
    constraint::Constraint
    score::Float64
end

@kwdef struct ShapleyAnalysis
    results::Vector{ShapleyResult}
end

Base.show(io::IO, x::ShapleyResult) = print(io, "$(x.constraint)\tscore:$(x.score)")

Base.show(io::IO, x::ShapleyAnalysis) = begin
    println(io, "---- [shapley scores] -----")
    for (i, r) in enumerate(x.results)
        println(io, "\e[32m[$i]: $(r.constraint)\e[0m")
        println(io, "$(r.score)")
    end
end


function shapley_calculation(analysis::OWLAnalysis; samples = 1000)
    constraints = map(x -> x.constraint, analysis.results)
    axioms = OWLAxioms(constraints, analysis.namespaces, analysis.decay_factor)
    ctx = ShapleyContext(axioms = axioms, samples = samples)
    return calculate(ctx)
end

function calculate(ctx::ShapleyContext)
    constraints = ctx.axioms.constraints
    n = length(constraints)
    sample_scores = [zeros(Float64, n) for _ in 1:ctx.samples]

    @threads for sample in 1:ctx.samples
        scores = sample_scores[sample]

        perm = randperm(n)
        subset = Constraint[]
        prev = shapley_eval(ctx, subset)

        for idx in perm
            push!(subset, constraints[idx])
            value = shapley_eval(ctx, subset)
            scores[idx] += value - prev
            prev = value
        end
    end
    scores = reduce(+, sample_scores)
    real_scores = scores ./ ctx.samples

    results = Vector{ShapleyResult}()
    for (i, value) in enumerate(real_scores)
        push!(results, ShapleyResult(constraint = constraints[i], score = value))
    end
    return ShapleyAnalysis(results)
end

function shapley_eval(ctx::ShapleyContext, constraints::Vector{Constraint})
    constraints = append_tbox_root(constraints)
    axioms = OWLAxioms(constraints, ctx.axioms.namespaces, ctx.axioms.α)
    ctx = TBoxContext(axioms = axioms)
    prepare!(ctx)

    return calculate(ctx).violation_score
end
