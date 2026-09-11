using Graphs

Base.show(io::IO, ctx::TBoxContext) = begin
    println(io, ctx.axioms)
    println(io, "---- [graph] -----")
    for v in vertices(ctx.dag)
        v_name = "$v:$(ctx.id_to_node[v])"
        neighbours = outneighbors(ctx.dag, v)
        neighbour_names = map(n -> "$n:$(ctx.id_to_node[n])", neighbours)
        if isempty(neighbours)
            println(io, "$v_name -> Nothing")
        else
            println(io, "$v_name -> [", join(neighbour_names, ", "), "]")
        end
    end
end

Base.show(io::IO, c::SubClassOf) = print(io, "$(c.subject) ⊑ $(c.parent)")
Base.show(io::IO, c::DisjointWith) = print(io, "$(c.subject) ⊓ $(c.object) = ∅")

constraint_sort_key(c::SubClassOf) = (c.sort_key, c.parent, c.subject)
constraint_sort_key(c::DisjointWith) = (c.sort_key, c.subject, c.object)
constraint_result_sort_key(r::ConstraintResult) = (r.constraint.sort_key)

Base.:(==)(a::Constraint, b::Constraint) = "$a" == "$b"
Base.hash(x::Constraint, h::UInt) = hash("$x", h)

