using ConfigEnv

if get(ENV, "DOCKER", "false") == "true"
    dotenv("/app/.env.docker")
else
    dotenv(joinpath(@__DIR__, "../../.env"))
end

