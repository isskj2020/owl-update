using LibGit2


function git_add(repo::LibGit2.GitRepo, absolute_path::String)
    path = git_path(repo, absolute_path)
    LibGit2.add!(repo, path)
end

function git_path(repo::LibGit2.GitRepo, absolute_path::String)
    repo_path = LibGit2.path(repo) * "/"
    path = realpath(absolute_path)
    return replace(path, (repo_path => ""))
end

function git_sig(user::NamedTuple)
    return LibGit2.Signature(user.name, user.email, Int(round(time())), 0)
end

function git_commit(git_repo::LibGit2.GitRepo, sig, message::String)
    return LibGit2.commit(git_repo, message; author = sig, committer = sig)
end


function git_log_item(c::LibGit2.GitCommit)
    author = LibGit2.author(c)
    date = unix2datetime(author.time)
    return (
        hash = string(LibGit2.GitHash(c)),
        author = "$(author.name)/$(author.email)",
        date = unix2datetime(author.time),
        message = LibGit2.message(c)
    )
end
