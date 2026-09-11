using Graphs

@kwdef mutable struct TBoxContext <: OWLContext
    axioms::OWLAxioms
    dag::SimpleDiGraph = SimpleDiGraph()
    node_to_id::Dict{String, Int} = Dict()
    id_to_node::Dict{Int, String} = Dict()
end


# === Constraints =============================================

@kwdef mutable struct SubClassOf <: Constraint
    id::String = ""
    sort_key::Int = 1
    type::String = K_SUBCLASS_OF
    subject::String
    parent::String
    priority::Float64 = K_DEFAULT_PRIORITY
end

@kwdef mutable struct DisjointWith <: Constraint
    id::String = ""
    sort_key::Int = 2
    type::String = K_DISJOINT_WITH
    subject::String
    object::String
    priority::Float64 = K_DEFAULT_PRIORITY
end

