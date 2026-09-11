using JSON, Random, OrderedCollections, Format


function read_tbox_json(path::String)
    json = JSON.parse(open(path, "r"))
    return read_tbox_json(json)
end

function read_tbox_json(json::JSON.Object)
    namespaces = OrderedDict{String, String}()
    for (k, v) in get(json, "namespaces", Dict())
        namespaces[String(k)] = v
    end
    α = get(json, "alpha", K_DEFAULT_DECAY_FACTOR)

    constraints = Vector{Constraint}()
    for c in get(json, "results", Dict())
        if c.constraint.type === K_SUBCLASS_OF
            push!(constraints, from_json_subclass_of(c.constraint))
        elseif c.constraint.type === K_DISJOINT_WITH
            push!(constraints, from_json_disjoint_with(c.constraint))
        end
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

function convert_tbox_json_axioms(json::JSON.Object)
    α = get(json, "alpha", K_DEFAULT_DECAY_FACTOR)
    namespaces = OrderedDict{String, String}()
    for (k, v) in get(json, "namespaces", Dict())
        namespaces[String(k)] = v
    end
    constraints = Vector{Constraint}()
    for c in get(json, "constraints", Dict())
        if c.type === K_SUBCLASS_OF
            push!(constraints, from_json_subclass_of(c))
        elseif c.type === K_DISJOINT_WITH
            push!(constraints, from_json_disjoint_with(c))
        end
    end

    unique!(constraints)
    sort!(namespaces)
    sort!(constraints; by = constraint_sort_key)

    constraints = append_tbox_root(constraints)
    return OWLAxioms(constraints, namespaces, α)
end

function read_tbox_json_axioms(json::JSON.Object)
    axioms = convert_tbox_json_axioms(json)
    context = TBoxContext(axioms = axioms)
    prepare!(context)
    return context
end

function save_tbox_json(analysis::OWLAnalysis, filepath::String)
    open(filepath, "w") do io
        json = JSON.json(analysis; pretty = true)
        println(io, json)
    end
end


function from_json_subclass_of(d)
    c = SubClassOf(subject = d.subject,
                     parent = d.parent,
                     priority = Float64(d.priority))
    c.id = "$c"
    return c
end

function from_json_disjoint_with(d)
    c = DisjointWith(subject = d.subject,
                        object = d.object,
                        priority = Float64(d.priority))
    c.id = "$c"
    return c
end
