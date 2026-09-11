using Plots

function draw_heatmap(factor = 0.5)
    initial_design(factor)
    revised_design(factor)
end

function initial_design(λ = 0.5)
    priority = 0.0:0.01:1.0
    depth = 0.0:0.01:1.0
    repair_cost = [p * λ^d for p in priority, d in depth]

    p = heatmap(depth, priority, repair_cost, xlabel = "Depth", ylabel = "Priority", colorbar_title = "Repair Cost")

    savefig(p, "heatmap_initial_design_$λ.pdf")
end

function revised_design(α = 0.5)
    priority = 0.0:0.01:1.0
    impact = 0.0:0.01:1.0
    repair_cost = [α * p + (1 - α) * i for p in priority, i in impact]

    p = heatmap(impact, priority, repair_cost, xlabel = "Impact", ylabel = "Priority", colorbar_title = "Repair Cost")

    savefig(p, "heatmap_revised_design_$α.pdf")
end
