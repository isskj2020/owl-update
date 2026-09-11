using HTTP, UUIDs, Dates, Graphs, JSON

function auth_cookie(session::String, remember_me::Bool)
    @info session, remember_me
    x_session = "X-Session=$(session); httpOnly; Path=/; SameSite=Lax"
    if remember_me
        x_session = "$(x_session);Max-Age=259200030"
    end
    @info x_session
    return Dict{String,String}([ "Set-Cookie" => x_session])
end
auth_clear_cookie() = Dict{String,String}([ "Set-Cookie" => "X-Session=; httpOnly; Path=/; Max-Age=0; SameSite=Lax" ])

function api_router_get_alive(req::HTTP.Request)
    return Response(status = 200, body = (message = "alive",))
end

function api_router_auth_signup(req::HTTP.Request)
    json = get_request_json_body(req)
    res = auth_signup(json.name, json.email, json.password)
    return Response(status = 200, headers = auth_cookie(res.session, json.remember_me), body = res)
end

function api_router_auth_login(req::HTTP.Request)
    json = get_request_json_body(req)
    res = auth_login(json.email, json.password)
    return Response(status = 200, headers = auth_cookie(res.session, json.remember_me), body = res)
end

function api_router_auth_logout(req::HTTP.Request)
    message = "logged out"
    return Response(status = 200, headers = auth_clear_cookie(), body = ( message = message, ))
end

function api_router_auth_verify(req::HTTP.Request)
    session = get_request_session(req)
    res = auth_verify_session(session)
    return Response(status = 200, body = res.user)
end

#
# repositories
#
function api_router_create_repo(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    json = get_request_json_body(req)
    res = create_repo(payload.user, json.name, json.description, json.remote_origin)
    return Response(status = 201, body = res)
end

function api_router_fetch_repos(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    res = fetch_repos(payload.user)
    return Response(status = 200, body = res)
end


#
# repository info
#
function api_router_fetch_repo_files(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    res = fetch_repo_files(payload.user, repo)
    return Response(status = 200, body = res)
end

function api_router_fetch_repo_status(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    res = fetch_repo_status(payload.user, repo)
    return Response(status = 200, body = res)
end

function api_router_fetch_repo_logs(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    queries = get_request_queries(req)
    repo = HTTP.getparams(req)["repo"]
    res = fetch_repo_logs(payload.user, repo)
    return Response(status = 200, body = res)
end

function api_router_fetch_repo_diffs(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    res = fetch_repo_diffs(payload.user, repo)
    return Response(status = 200, body = res)
end

#
# repository update
#
function api_router_repo_add_file(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    multipart = HTTP.parse_multipart_form(req)
    file = nothing
    json = nothing
    for part in multipart
        try
            json = JSON.parse(part.data)
        catch
            file = part
        end
    end
    repo = HTTP.getparams(req)["repo"]
    data = String(take!(file.data))
    res = repo_add_file(payload.user, repo, json.filepath, data)
    return Response(status = 201, body = res)
end

function api_router_repo_add_directory(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = repo_add_directory(payload.user, repo, json.filepath)
    return Response(status = 201, body = res)
end

function api_router_repo_commit(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = repo_commit(payload.user, repo, json.filepath, json.message)
    return Response(status = 201, body = res)
end

function api_router_repo_update(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = owl_update(payload.user, repo, json.filepath, json.axioms)
    return Response(status = 201, body = res)
end

function api_router_repo_reset(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = repo_reset(payload.user, repo, json.filepath)
    return Response(status = 201, body = res)
end

#
# owl load
#
function api_router_owl_load(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = owl_load(payload.user, repo, json.filepath)
    return Response(status = 200, body = res)
end

function api_router_owl_load_shapley(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    repo = HTTP.getparams(req)["repo"]
    json = get_request_json_body(req)
    res = owl_load_shapley(payload.user, repo, json.filepath)
    return Response(status = 200, body = res)
end

#
# local ml
#
function api_router_ml_similarity_llm(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    json = get_request_json_body(req)
    res = fetch_similarity_llm(payload.user, json)
    return Response(status = 200, body = res)
end
function api_router_eval_ml_similarity_llm(req::HTTP.Request)
    json = get_request_json_body(req)
    res = eval_similarity_llm(json)
    return Response(status = 200, body = res)
end

function api_router_ml_similarity_embedding(req::HTTP.Request)
    session = get_request_session(req)
    payload = auth_verify_session(session)
    json = get_request_json_body(req)
    res = fetch_similarity_embedding(payload.user, json)
    return Response(status = 200, body = res)
end

function api_router_eval_ml_similarity_embedding(req::HTTP.Request)
    model = HTTP.getparams(req)["model"]
    json = get_request_json_body(req)
    res = eval_similarity_embedding(model, json)
    return Response(status = 200, body = res)
end

function api_router_ml_models(req::HTTP.Request)
    res = fetch_ml_models()
    return Response(status = 200, body = res)
end
