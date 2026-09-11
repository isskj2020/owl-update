Base.show(io::IO, x::OWLAxioms) = begin
    println(io, "---- [constraints] -----")
    for (i, c) in enumerate(x.constraints)
        println(io, "[$i]: $c")
    end
    println(io)
    println(io, "---- [namespaces] -----")
    for c in x.namespaces
        println(io, c)
    end
end

Base.show(io::IO, x::OWLAnalysis) = begin
    println("violation_score:$(x.violation_score) decay_factor:$(x.decay_factor)")
    println(io, x.results)
    println(io, "---- [nodes] -----")
    for n in x.nodes
        println(io, "$(x.nodemap[n.id])($(n.id)) v:$(Int(n.inconsistent))")
    end
    println(io)
    println(io, "---- [edges] -----")
    for n in x.edges
        println(io, "$(x.nodemap[n.source])($(n.source)) -> $(x.nodemap[n.target])($(n.target)) v:$(Int(n.violation))")
    end
    println(io)
end

Base.show(io::IO, results::Vector{ConstraintResult}) = begin
    println(io, "---- [constraints] -----")
    for (i, x) in enumerate(results)
        println(io, "\e[32m[$i]: $(x.constraint)\e[0m")
        println(io, "priority: $(x.constraint.priority)\tviolation: $(Int(x.violation))\tdepth: $(x.depth)\trepair_cost:$(x.repair_cost)")
    end
end
