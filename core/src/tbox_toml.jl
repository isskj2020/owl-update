using TOML, OrderedCollections

function read_tbox_toml(filepath::String)
    dict = TOML.parse(open(filepath, "r"))
    α = K_DEFAULT_DECAY_FACTOR
    for (k, v) in get(dict, "status", Dict())
        if k === "alpha"
            α = Float64(v)
        end
    end
    namespaces = OrderedDict{String, String}()
    for (k, v) in get(dict, "namespaces", Dict())
        namespaces[k] = v
    end

    constraints = Vector{Constraint}()

    for c in get(dict, K_SUBCLASS_OF, [])
        push!(constraints, from_toml_subclass_of(c))
    end
    for c in get(dict, K_DISJOINT_WITH, [])
        push!(constraints, from_toml_disjoint_with(c))
    end
    unique!(constraints)
    sort!(namespaces)
    sort!(constraints; by = constraint_sort_key)

    constraints = append_tbox_root(constraints)
    axioms = OWLAxioms(constraints, namespaces, α)
    context = TBoxContext(axioms = axioms)
    prepare!(context)
    return context
end

function save_tbox_toml(analysis::OWLAnalysis, filepath::String)
    open(filepath, "w") do io
        println(io, "[namespaces]")
        for (k, ns) in analysis.namespaces
            println(io, "\"$k\" = \"$ns\"")
        end
        println(io)
        println(io, "[status]")
        println(io, "violation_score = $(analysis.violation_score)")
        println(io, "alpha = $(analysis.α)")
        println(io)

        print_toml(io, analysis.results)
    end
end

function print_toml(io::IO, results::Vector{ConstraintResult})
    if isempty(results)
        return
    end
    sort!(results; by = constraint_result_sort_key)
    for res in results
        println(io, "[[$(res.constraint.type)]]")
        print_toml(io, res.constraint)
        println(io, "priority = $(res.constraint.priority)")
        println(io, "violation = $(Int(res.violation))")
        println(io, "depth = $(res.depth)")
        println(io, "repair_cost = $(res.repair_cost)")
        println(io)
    end
end

function print_toml(io::IO, c::SubClassOf)
    println(io, "subject = \"$(c.subject)\"")
    println(io, "parent = \"$(c.parent)\"")
end

function print_toml(io::IO, c::DisjointWith)
    println(io, "subject = \"$(c.subject)\"")
    println(io, "object = \"$(c.object)\"")
end

function from_toml_subclass_of(d::AbstractDict)
    c = SubClassOf(subject = d["subject"],
                   parent = d["parent"],
                   priority = get_value(Float64, d, "priority", 1.0))
    c.id = "$c"
    return c
end

function from_toml_disjoint_with(d::AbstractDict)
    c = DisjointWith(subject = d["subject"],
                     object = d["object"],
                     priority = get_value(Float64, d, "priority", 1.0))
    c.id = "$c"
    return c
end

