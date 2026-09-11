using Graphs

function graph_nodes(ctx::TBoxContext, inconsistency_nodes::Set{Int})
    return [GraphNode(id = id, inconsistent = id in inconsistency_nodes)
            for id in vertices(ctx.dag)]
end

function graph_edge(ctx::TBoxContext, result::ConstraintResult)
    c = result.constraint
    if c isa SubClassOf
        return GraphEdge(
            source = ctx.node_to_id[c.subject],
            target = ctx.node_to_id[c.parent],
            violation = result.violation,
            type = c.type,
            label = "p=$(format("{:.2f}", c.priority))",
        )
    elseif c isa DisjointWith
        return GraphEdge(
            source = ctx.node_to_id[c.subject],
            target = ctx.node_to_id[c.object],
            violation = result.violation,
            type = c.type,
            label = "p=$(format("{:.2f}", c.priority))",
        )
    end
end

function append_tbox_root(constraints::Vector{Constraint})
    children = Set{String}()
    parents  = Set{String}()
    classes = Set{String}()

    for c in constraints
        if c isa SubClassOf
            push!(children, c.subject)
            push!(parents, c.parent)
            push!(classes, c.subject)
            push!(classes, c.parent)
        elseif c isa DisjointWith
            push!(classes, c.subject)
            push!(classes, c.object)
        end
    end

    roots = setdiff(parents, children)
    isolated = setdiff(classes, union(parents, children))

    new_constraints = Vector{Constraint}(constraints)
    for r in union(roots, isolated)
        if r != K_OWL_THING
            value = SubClassOf(subject = r, parent = K_OWL_THING)
            push!(new_constraints, value)
        end
    end
    unique!(new_constraints)
    sort!(new_constraints; by = constraint_sort_key)
    return new_constraints
end

