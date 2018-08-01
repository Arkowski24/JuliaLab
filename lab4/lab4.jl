using DifferentialEquations
using DataFrames
using CSV
using Gadfly
using RDatasets

function lotka_volter_problem(du, u, p, t)
    du[1] = p[1] * u[1] - p[2] * u[1] * u[2]
    du[2] = p[3] * u[1] * u[2] - p[4] * u[2]
end

function solve_equation(A::Float64, B::Float64, C::Float64, D::Float64,
      x0::Float64, y0::Float64, identifier::String, filename::String)
      #A - rate of grow (Prey), B - rate of predation
      #C - rate of grow (Predator), D - rate of death
      #X - number of prey, Y - number of predators
     u0 = [x0; y0]
     tspan = (0.0, 100.0)
     p = [A, B, C, D]
     problem = ODEProblem(lotka_volter_problem, u0, tspan, p)
     sol = solve(problem, RK4())

     df = DataFrame(t = sol.t, x = [r[1] for r in sol.u],
      y = [r[2] for r in sol.u], experiment = [identifier for r in sol.u])
     writetable(filename, df)
end

function load_results(filenames::Array{String})
    df = CSV.read(filenames[1], weakrefstrings=false, nullable=false)
    for i in 2:length(filenames)
        rdf = CSV.read(filenames[i], df, append=true, weakrefstrings=false, nullable=false)
    end
    df
end

function analyse_results(filenames::Array{String})
    df = load_results(filenames)

    df2 = by(df, :experiment, dfr -> DataFrame(
        x_max = maximum(dfr[:x]), x_min = minimum(dfr[:x]), x_mean = mean(dfr[:x]),
        y_max = maximum(dfr[:y]), y_min = minimum(dfr[:y]), y_mean = mean(dfr[:y]))
    )

    df[:x_y_diff] = map((x, y) -> x - y, df[:x], df[:y])
    println(df2)
    println(df)
end

function draw_sub_plots()
    df = load_results(["lab4/exp1.csv", "lab4/exp2.csv", "lab4/exp3.csv", "lab4/exp4.csv"])
    df[:x_y_diff] = map((x, y) -> x - y, df[:x], df[:y])

    rename!(df, :x, :Prey)
    rename!(df, :y, :Predators)
    rename!(df, :x_y_diff, :Difference)

    #set_default_plot_size(8cm, 120cm)
    p = plot(df,
     Guide.XLabel("Time by Experiment"),
     Guide.YLabel("Values"),
     Guide.Title("Sub Plot"),
     xgroup=:experiment,
     x=:t, y=Col.value(:Prey, :Predators, :Difference),
     color=Col.index(:Prey, :Predators, :Difference),
     Geom.subplot_grid(Geom.path, free_y_axis=true))
    display(p)
end

function draw_phase_plot()
    layers = Vector{Layer}()
    df = load_results(["lab4/exp1.csv", "lab4/exp2.csv", "lab4/exp3.csv", "lab4/exp4.csv"])
    colors = ["red", "blue", "green", "orange"]
    infos = ["Exp 1 (1, 1, 1, 1, 10, 2)",
     "Exp 2 (4, 3, 2, 1, 10, 2)",
     "Exp 3 (1, 2, 1, 2, 10, 2)",
     "Exp 4 (4, 1, 1, 0.5, 10, 2)"]
    i = 1

    for subdf in groupby(df, :experiment)
        push!(layers, layer(subdf, x=:x, y=:y,
         Geom.path, Theme(default_color=colors[i]))...)
        i = i + 1
    end

    p = plot(layers,
     Guide.XLabel("Prey"),
     Guide.YLabel("Predators"),
     Guide.Title("Phase Plot"),
     Guide.manual_color_key("Legend (a, b, c, d, x0, y0)", infos, colors))
    display(p)
end
