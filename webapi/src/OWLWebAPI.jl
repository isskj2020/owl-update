module OWLWebAPI

include("env.jl")
include("errors.jl")
include("response.jl")
include("resource/users.jl")
include("resource/repositories.jl")

include("components/gitutil.jl")
include("components/auth.jl")
include("components/db.jl")
include("components/repo_info.jl")
include("components/repo_update.jl")
include("components/owl.jl")
include("components/ml.jl")

include("middlewares.jl")

include("api_router.jl")
include("api.jl")


end # module webapi
