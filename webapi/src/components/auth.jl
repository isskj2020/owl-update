using DataFrames, UUIDs, Dates, Bcrypt, Base64, JSONWebTokens


function auth_signup(name::String, email::String, password::String)
    sql = """
    SELECT * FROM users WHERE email = ?
    """
    users = db_fetch(sql, [email])
    if !isempty(users)
        throw(AuthError(message = "$email has already registered"))
    end
    hash = Bcrypt.GenerateFromPassword(password) |> x -> String(x)
    user = User(
        role = "user",
        name = name,
        email = email,
        password_hash = hash,
    )
    df = DataFrame([user])
    db_insert(df, "users")
    return auth_login(email, password)
end

function auth_login(email::String, password::String)
    sql = """
    SELECT * FROM users WHERE email = ?
    """
    users = db_fetch(sql, [email])
    if isempty(users)
        throw(AuthError(message = "$email is not registered. please signin first."))
    end
    user = first(users)
    if !Bcrypt.CompareHashAndPassword(user[:password_hash], password)
        throw(AuthError(message = "$email password is incorrect"))
    end
    payload = Dict(
       "sub" => user.id,
       "name" => user.name,
       "email" => user.email,
       "iat" => datetime2unix(now()),
    )

    encoding = JSONWebTokens.RS256(ENV["JWT_PRIVATE_KEY_PATH"])
    session = JSONWebTokens.encode(encoding, payload)

    return (
        user = (
            id = user.id,
            role = user.role,
            name = user.name,
            email = user.email,
            updated_at = user.updated_at,
        ),
        session = session,
    )
end

function auth_verify_session(session)
    if session == nothing
        throw(AuthError(message = "session is invalid."))
    end
    encoding = JSONWebTokens.RS256(ENV["JWT_PUBLIC_KEY_PATH"])
    payload = JSONWebTokens.decode(encoding, session)
    sql = """
    SELECT count(id) FROM users WHERE id = ?
    """
    uid = payload["sub"]
    users = db_fetch(sql, [uid])
    if isempty(users)
        throw(AuthError(message = "user_id $uid doesn't exist"))
    end
    return (
        user = (
            id = payload["sub"],
            name = payload["name"],
            email = payload["email"],
        ),
    )
end

