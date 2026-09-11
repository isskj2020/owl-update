using HTTP, JSON

using OWLUpdate

const instruction = """
Estimate semantic similarity score between two ontology concepts.
Input: A and B are class names.
You estimate similarity score between A and B.
0.01 is semantically far from each other.
0.99 is semantically close to each other.
Return a score from 0.01 to 1.0 as a continuous similarity score.
"""

function fetch_ml_models()
    res = HTTP.get("$(ENV["LLAMA_HOST_URL"])/v1/models";
                   headers = ["Content-Type" => "application/json"])
    body = JSON.parse(String(res.body))
    models = []
    for (i, model) in enumerate(body.models)
        push!(models, ( info = "LLM:$(model.name)",))
    end

    res = HTTP.get("$(ENV["EMBEDDING_HOST_URL"])/models";
                   headers = ["Content-Type" => "application/json"])
    b = String(res.body)
    body = JSON.parse(b)
    for (i, name) in enumerate(body)
        push!(models, ( info = "Embedding:$(name)",))
    end

    return (
        models = models,
    )
end

function fetch_similarity_llm(user::NamedTuple, json::JSON.Object)

    axioms = convert_tbox_json_axioms(json)
    contents = create_message(axioms.constraints)
    results = Float64[]
    for i in eachindex(contents)
        content = JSON.json(contents[i])
        @info "input content" content
        request = (
                   messages = [
                               ( role = "system", content = instruction,),
                               ( role = "user", content = content, ),
                              ],
                   grammar = make_score_grammar(),
                   temperature = 0.7,
                   top_p = 0.8,
                   top_k = 20,
                   min_p = 0,
                   presence_penalty = 1.9,
                   max_tokens = 100,
                   chat_template_kwargs = ( enable_thinking = false,)
                  )

        res = HTTP.post("$(ENV["LLAMA_HOST_URL"])/v1/chat/completions";
                        headers = ["Content-Type" => "application/json"],
                        body = JSON.json(request))
        body = JSON.parse(res.body)
        output = body.choices[1].message.content
        @info "output content" output
        try
            value = parse(Float64, output)
            push!(results, value)
        catch e
            @error e
            push!(results, 1.0)
        end
    end

    update_priority!(axioms, results)
    return JSON.json(axioms)
end

function eval_similarity_llm(json::JSON.Object)
    @info json
    contents = []
    for arr in get(json, "concepts", [])
        push!(contents, arr)
    end

    results = Float64[]
    for i in eachindex(contents)
        content = JSON.json(contents[i])
        @info "input content" content
        request = (
                   messages = [
                               ( role = "system", content = instruction,),
                               ( role = "user", content = content, ),
                              ],
                   grammar = make_score_grammar(),
                   temperature = 0.7,
                   top_p = 0.8,
                   top_k = 20,
                   min_p = 0,
                   presence_penalty = 1.9,
                   max_tokens = 100,
                   chat_template_kwargs = ( enable_thinking = false,)
                  )

        res = HTTP.post("$(ENV["LLAMA_HOST_URL"])/v1/chat/completions";
                        headers = ["Content-Type" => "application/json"],
                        body = JSON.json(request))
        body = JSON.parse(res.body)
        output = body.choices[1].message.content
        @info "output content" output
        try
            value = parse(Float64, output)
            push!(results, value)
        catch e
            @error e
            push!(results, 1.0)
        end
    end

    return JSON.json(results)
end

function fetch_similarity_embedding(user::NamedTuple, json::JSON.Object)
    axioms = convert_tbox_json_axioms(json)

    content = create_message(axioms.constraints)

    res = HTTP.post("$(ENV["EMBEDDING_HOST_URL"])/similarity/bge";
        headers = ["Content-Type" => "application/json",
                   "Connection" => "close",
                  ],
        body = JSON.json(content))

    scores = JSON.parse(String(res.body))
    @info "embedding message:$scores"

    update_priority!(axioms, scores)
    return JSON.json(axioms)
end


function eval_similarity_embedding(model::String, json::JSON.Object)
    @info model, json
    contents = []
    for arr in get(json, "concepts", [])
        push!(contents, arr)
    end
    @info "request contents" contents

    res = HTTP.post("$(ENV["EMBEDDING_HOST_URL"])/similarity/$model";
        headers = ["Content-Type" => "application/json",
                   "Connection" => "close",
                  ],
        body = JSON.json(contents))

    return res.body
end

function update_priority!(axioms::OWLAxioms, scores)
    for (i, c) in enumerate(axioms.constraints)
        raw_score = get(scores, i, "1")
        p = parse(Float64, "$raw_score")
        if c isa SubClassOf && c.parent !== K_OWL_THING
            axioms.constraints[i].priority = p
        end
    end
end


function create_message(constraints)
    concepts = []
    for c in constraints
        if c isa SubClassOf
            push!(concepts, [c.subject, c.parent])
        elseif c isa DisjointWith
            push!(concepts, [c.subject, c.object])
        end
    end
    return concepts
end

function make_score_grammar()
    return """
    root ::= score
    score ::= "0." digit digit digit digit
    digit ::= [0-9]
    """
end
