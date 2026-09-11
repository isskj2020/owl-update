using MySQL, DataFrames, ConcurrentUtilities

export db_init
export db_release

db_connect() = DBInterface.connect(
    MySQL.Connection,
    ENV["DB_HOST"],
    ENV["DB_USER"],
    ENV["DB_PASS"];
    db = ENV["DB_NAME"],
    port = parse(Int, ENV["DB_PORT"]),
    protocol = MySQL.API.MYSQL_PROTOCOL_TCP
)
db_close(conn) = DBInterface.close!(conn)

const DB_POOL_SIZE = parse(Int, ENV["DB_POOL_SIZE"])
const DB_POOL = Channel{MySQL.Connection}(DB_POOL_SIZE)

function db_init()
    for _ in 1:DB_POOL_SIZE
        put!(DB_POOL, db_connect())
    end
end

function db_release()
    while isready(DB_POOL)
        conn = take!(DB_POOL)
        db_close(conn)
    end
end

function with_connection(f)
    st = time_ns()
    conn = take!(DB_POOL)
    healthy = true
    try
        res = f(conn)
        return res
    catch e
        @error "[Error]" exception=(e, catch_backtrace())
        healthy = false
        rethrow()
    finally
        if healthy
            put!(DB_POOL, conn)
        else
            db_close(conn)
            put!(DB_POOL, db_connect())
        end
    end
end

function db_insert(data, table::String)
    df = DataFrame(data)
    keys = join(map(x -> "?", names(df)), ",")
    for row in eachrow(df)
        sql = "INSERT INTO $table VALUES ( $keys )"
        db_exec(sql, Vector(row))
    end
    return df
end

function db_fetch(sql::String, params::Vector)
    @info "[SQL]" sql params
    return with_connection() do conn
        stmt = DBInterface.prepare(conn, sql)
        try
            DataFrame(DBInterface.execute(stmt, params))
        finally
            DBInterface.close!(stmt)
        end
    end
end

function db_fetch(sql::String)
    @info "[SQL]" sql
    return with_connection() do conn
        DataFrame(DBInterface.execute(conn, sql))
    end
end

function db_exec(sql::String, params::Vector)
    @info "[SQL]" sql params
    return with_connection() do conn
        stmt = DBInterface.prepare(conn, sql)
        try
            cursor = DBInterface.execute(stmt, params)
            DBInterface.lastrowid(cursor)
        finally
            DBInterface.close!(stmt)
        end
    end
end
