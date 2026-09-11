using HTTP

Router = HTTP.Router()
HTTP.register!(Router, "GET", "/alive", api_router_get_alive)
HTTP.register!(Router, "POST", "/signup", api_router_auth_signup)
HTTP.register!(Router, "POST", "/login", api_router_auth_login)
HTTP.register!(Router, "POST", "/logout", api_router_auth_logout)
HTTP.register!(Router, "GET", "/verify", api_router_auth_verify)

# repositories
HTTP.register!(Router, "GET", "/owl/repos", api_router_fetch_repos)
HTTP.register!(Router, "POST", "/owl/create", api_router_create_repo)

# repository info
HTTP.register!(Router, "GET", "/owl/{repo}/files", api_router_fetch_repo_files)
HTTP.register!(Router, "GET", "/owl/{repo}/status", api_router_fetch_repo_status)
HTTP.register!(Router, "GET", "/owl/{repo}/logs", api_router_fetch_repo_logs)
HTTP.register!(Router, "GET", "/owl/{repo}/diffs", api_router_fetch_repo_diffs)

# repository update
HTTP.register!(Router, "POST", "/owl/{repo}/file/add", api_router_repo_add_file)
HTTP.register!(Router, "POST", "/owl/{repo}/dir/add", api_router_repo_add_directory)
HTTP.register!(Router, "POST", "/owl/{repo}/commit", api_router_repo_commit)
HTTP.register!(Router, "POST", "/owl/{repo}/update", api_router_repo_update)
HTTP.register!(Router, "POST", "/owl/{repo}/reset", api_router_repo_reset)

# owl load
HTTP.register!(Router, "POST", "/owl/{repo}/load", api_router_owl_load)
HTTP.register!(Router, "POST", "/owl/{repo}/load/shapley", api_router_owl_load_shapley)

# local llm / embeddings
HTTP.register!(Router, "POST", "/owl/ml/similarity/llm", api_router_ml_similarity_llm)
HTTP.register!(Router, "POST", "/owl/ml/similarity/embedding", api_router_ml_similarity_embedding)
HTTP.register!(Router, "GET", "/owl/ml/models", api_router_ml_models)
HTTP.register!(Router, "POST", "/eval/ml/similarity/llm", api_router_eval_ml_similarity_llm)
HTTP.register!(Router, "POST", "/eval/ml/similarity/embedding/{model}", api_router_eval_ml_similarity_embedding)

function serve()
    db_init()
    ip = String(ENV["WEBAPI_DOMAIN"])
    port = parse(Int, ENV["WEBAPI_PORT"])
    @info "serving.. $(ip):$(port)"
    return HTTP.serve(
        Router |>
        ResponseJSONMiddleware |>
        ErrorMiddleware |>
        CORSMiddleware |>
        LoggingMiddleware,
        ip, port
    )
end
