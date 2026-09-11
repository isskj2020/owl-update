include("OWLWebAPI.jl")

using .OWLWebAPI, ConfigEnv

dotenv(".env.docker")

OWLWebAPI.serve()
