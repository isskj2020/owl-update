module OWLUpdate

const MODULE = "[OWLUpdate]"

include("axioms.jl")
include("axioms_helper.jl")
include("util.jl")
include("graph.jl")
include("calc.jl")
include("reasoner.jl")
include("shapley.jl")

include("tbox_axioms.jl")
include("tbox_axioms_helper.jl")

include("tbox_calc.jl")
include("tbox_graph.jl")
include("tbox_json.jl")
include("tbox_toml.jl")
include("tbox_xml.jl")

include("tools.jl")

export OWLAxioms, OWLAnalysis, OWLContext, ShapleyAnalysis,
       ConstraintResult, ShapleyResult, TBoxContext,
       ShapleyContext, Constraint, SubClassOf, DisjointWith,
       K_OWL_THING, K_SUBCLASS_OF, K_DISJOINT_WITH,
       read_tbox_xml, save_tbox_xml,
       read_tbox_toml, save_tbox_toml,
       read_tbox_json, read_tbox_json_axioms, convert_tbox_json_axioms, save_tbox_json,
       calculate, delete_constraint!,
       transform_tbox_file, transform_tbox_bulk_files


end # module core
