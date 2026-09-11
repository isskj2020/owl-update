const HERMIT_PATH = joinpath(@__DIR__,  "HermiT.jar")

function use_hermiT(filepath::String)
    results = read(`java -jar $HERMIT_PATH -U $filepath`, String) |>
        x -> split(x, "\n") |>
        x -> map(i -> replace(i, ("\t" => "")), x) |>
        x -> filter(i -> !(contains(i, "owl:Nothing") || isempty(i)), x)
    return results
end

