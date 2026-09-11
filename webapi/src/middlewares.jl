using HTTP, JSON

function cors_headers(req::HTTP.Request)
    headers = Dict{String, String}()
    headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Cookie"
    headers["Access-Control-Allow-Credentials"] = "true"
    headers["Content-Type"] = "application/json"
    origin = HTTP.header(req, "Origin")
    if startswith(origin, "http://localhost:")
        headers["Access-Control-Allow-Origin"] = origin
    end
    return headers
end

function get_request_json_body(req::HTTP.Request)
    type = HTTP.header(req, "Content-Type", "")
    if startswith(type, "application/json")
        return JSON.parse(String(req.body))
    end
    return nothing
end

function get_request_queries(req::HTTP.Request)
    uri = HTTP.URI(req.target)
    return HTTP.queryparams(uri.query)
end

function get_request_session(req::HTTP.Request)
    cookies = get(req.headers, "Cookie", nothing)
    if cookies !== nothing
        for c in split(cookies, ";")
            kv = split(strip(c), "=")
            if lowercase(kv[1]) == "x-session"
                return String(kv[2])
            end
        end
    end
    return nothing
end


function LoggingMiddleware(handler)
    return function(req::HTTP.Request)
        res = handler(req)
        @info "[API]" req res
        return res
    end
end

function CORSMiddleware(handler)
    return function(req::HTTP.Request)
        cors = cors_headers(req)
        if req.method == "OPTIONS"
            return HTTP.Response(204, cors, HTTP.EmptyBody())
        end
        res = handler(req)
        if res.headers isa Dict
            merge!(res.headers, cors)
        elseif res.headers isa HTTP.Headers
            merge!(res.headers, cors)
        end
        @info res.headers
        return res
    end
end


function ResponseJSONMiddleware(handler)
    return function(req::HTTP.Request)
        res = handler(req)
        body = if res.body isa NamedTuple || res.body isa JSON.Object
            body = JSON.json(res.body)
        else
            res.body
        end
        headers = HTTP.Headers(res.headers)
        return HTTP.Response(res.status, headers, body)
    end
end

function ErrorMiddleware(handler)
    return function(req::HTTP.Request)
        try
            return handler(req)
        catch e
            @error e
            traces = stacktrace(catch_backtrace())
            for t in traces
                @error t
            end
            headers = HTTP.Headers()
            status = 500
            body = ( message = "$e", )
            if e isa ApiError
                body = ( message = e.message, )
                status = e.status
            elseif e isa ErrorException
                body = ( message = e.msg, )
            end
            return HTTP.Response(status, headers, JSON.json(body))
        end
    end
end


