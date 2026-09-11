using OWLUpdate, Test, Graphs, JSON

@testset "All Tests" begin
    ctx = read_tbox_xml("./test.xml")
    analysis = calculate(ctx)
    @test analysis.violation_score === 3.0
    @test length(analysis.namespaces) === 7
    @test length(analysis.results) === 7
    @test length(analysis.nodemap) === 6

    ctx.axioms.constraints === 7
    delete_constraint!(ctx, ctx.axioms.constraints[1])
    ctx.axioms.constraints === 6

    save_tbox_xml(analysis, "./test.out.xml")

    ctx = read_tbox_toml("./test.toml")
    analysis = calculate(ctx)
    @test analysis.violation_score === 3.0
    @test length(analysis.namespaces) === 7
    @test length(analysis.results) === 7
    @test length(analysis.nodemap) === 6

    save_tbox_toml(analysis, "./test.out.toml")

    ctx = read_tbox_json("./test.json")
    analysis = calculate(ctx)
    @test analysis.violation_score === 3.0
    @test length(analysis.namespaces) === 7
    @test length(analysis.results) === 7
    @test length(analysis.nodemap) === 6

    save_tbox_json(analysis, "./test.out.json")

    ctx = ShapleyContext(axioms = ctx.axioms)
    shapley = calculate(ctx)
    @test length(shapley.results) === 7
    @test length(filter(x -> x.score > 0.1, shapley.results)) === 4

    constraints = map(x -> x.constraint, analysis.results)
    axioms = OWLAxioms(constraints, analysis.namespaces, analysis.decay_factor)
    json_axioms = JSON.json(axioms) |> x -> JSON.parse(x)

    ctx = read_tbox_json_axioms(json_axioms)
    analysis = OWLUpdate.calculate(ctx)

end
