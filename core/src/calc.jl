using Graphs

function calc_violation_score(results::Vector{ConstraintResult})
    violation_score = 0.0
    for (i, res) in enumerate(results)
        violation_score += res.constraint.priority * res.violation
    end
    return violation_score
end

function delete_constraint!(ctx::OWLContext, c::Constraint)
    filter!(x -> x.id != c.id, ctx.axioms.constraints)
    return ctx
end
