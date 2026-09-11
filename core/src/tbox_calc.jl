using Graphs

function prepare!(context::TBoxContext)
    nodes = Vector{String}()
    push!(nodes, K_OWL_THING)
    for c in context.axioms.constraints
        if c isa SubClassOf
            push!(nodes, c.subject)
            push!(nodes, c.parent)
        elseif c isa DisjointWith
            push!(nodes, c.subject)
            push!(nodes, c.object)
        end
    end
    unique!(nodes)
    node_to_id = Dict((n => i) for (i, n) in enumerate(nodes))
    id_to_node = Dict((i => n) for (i, n) in enumerate(nodes))

    dag = SimpleDiGraph(length(nodes), 0)

    for c in context.axioms.constraints
        if c isa SubClassOf
            src = node_to_id[c.parent]
            dst = node_to_id[c.subject]
            add_edge!(dag, src, dst)
        end
    end

    dag = repair_cyclic_graph(dag)
    context.dag = dag
    context.node_to_id = node_to_id
    context.id_to_node = id_to_node
end

function calc_tbox_depths(ctx::TBoxContext)
    depths = fill(0, nv(ctx.dag))
    for node in topological_sort(ctx.dag)
        for out in outneighbors(ctx.dag, node)
            depths[out] = max(depths[out], depths[node] + 1)
        end
    end
    return depths
end

function calc_tbox_impacts(ctx::TBoxContext)
    impacts = fill(0.0, nv(ctx.dag))
    for (node, id) in ctx.node_to_id
        value = dfs_descendants(ctx.dag, id) |> x -> Float64(length(x))
        impacts[id] = value
    end
    return impacts
end

function calculate(ctx::TBoxContext)::OWLAnalysis
    depths = calc_tbox_depths(ctx)
    impacts = calc_tbox_impacts(ctx)
    affected_nodes = []
    inconsistency_nodes = Set{Int}()
    disjoint_violations = Set{Int}()
    max_depth = maximum(depths)
    max_impact = maximum(impacts)

    for (i, c) in enumerate(ctx.axioms.constraints)
        if c isa DisjointWith
            aid = ctx.node_to_id[c.subject]
            bid = ctx.node_to_id[c.object]
            a_descendants = dfs_descendants(ctx.dag, aid)
            b_descendants = dfs_descendants(ctx.dag, bid)
            violated = intersect(a_descendants, b_descendants)

            union!(inconsistency_nodes, violated)
            if !isempty(violated)
                push!(disjoint_violations, i)
                for n in violated
                    affected = find_reachable_node_set(ctx.dag, n; bounds = Set([aid, bid]))
                    for a in affected
                        push!(affected_nodes, (n, a))
                    end
                end
            end
        end
    end

    results = Vector{ConstraintResult}()
    α = ctx.axioms.α
    for (i, c) in enumerate(ctx.axioms.constraints)
        violation = 0
        depth = 0
        impact = 0.0
        if c isa DisjointWith
            a = ctx.node_to_id[c.subject]
            b = ctx.node_to_id[c.object]

            depth = max(depths[a], depths[b])
            impact = max(impacts[a], impacts[b]) / max_impact
            violation = i in disjoint_violations

        elseif c isa SubClassOf
            a = ctx.node_to_id[c.subject]
            b = ctx.node_to_id[c.parent]

            depth = depths[b] + 1
            impact = impacts[a] / max_impact
            violation = !isempty(filter(x -> x[1] == a && x[2] == b, affected_nodes)) && c.parent != K_OWL_THING
        end

        repair_cost = if violation
            α * c.priority + (1 - α) * impact 
        else
            K_DEFAULT_REPAIR_COST
        end

        result = ConstraintResult(constraint = c,
                                  depth = depth,
                                  impact = impact,
                                  max_depth = max_depth,
                                  violation = violation,
                                  repair_cost = repair_cost)
        push!(results, result)
    end

    return OWLAnalysis(violation_score = calc_violation_score(results),
                       results = results,
                       nodes = graph_nodes(ctx, inconsistency_nodes),
                       edges = [graph_edge(ctx, result) for result in results],
                       nodemap = ctx.id_to_node,
                       namespaces = ctx.axioms.namespaces,
                       α = α) 
end
