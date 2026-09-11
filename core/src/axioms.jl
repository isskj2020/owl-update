using Random

const K_OWL_THING = "owl:Thing"
const K_SUBCLASS_OF = "subClassOf"
const K_DISJOINT_WITH = "disjointWith"
const K_DEFAULT_PRIORITY = 1
const K_DEFAULT_VIOLATION = false
const K_DEFAULT_REPAIR_COST = typemax(Int)
const K_DEFAULT_DECAY_FACTOR = 0.5
DEFAULT_ID() = randstring(32)

abstract type Constraint end
abstract type OWLContext end

@kwdef mutable struct GraphNode
    id::Int
    inconsistent::Bool
end

@kwdef mutable struct GraphEdge
    source::Int
    target::Int
    violation::Bool
    type::String
    label::String
end

@kwdef mutable struct ConstraintResult
    id::String = DEFAULT_ID()
    constraint::Constraint
    depth::Int64 = K_DEFAULT_DEPTH
    max_depth::Int64 = 0
    impact::Float64 = 0.0
    violation::Bool = K_DEFAULT_VIOLATION
    repair_cost::Float64 = K_DEFAULT_REPAIR_COST
end

@kwdef mutable struct OWLAxioms
    constraints::Vector{Constraint}
    namespaces::Dict{String, String}
    α::Float64
end

@kwdef mutable struct OWLAnalysis
    violation_score::Float64
    results::Vector{ConstraintResult}
    nodes::Vector{GraphNode}
    edges::Vector{GraphEdge}
    nodemap::Dict{Int, String}
    namespaces::Dict{String, String}
    α::Float64 = K_DEFAULT_DECAY_FACTOR
end

function calculate(calc::OWLContext)::OWLAnalysis
    throw(MethodError(calculate, (calc,)))
end

