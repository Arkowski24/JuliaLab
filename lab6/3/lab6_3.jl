using DataFrames
using Gadfly

include("0.jl")
include("1.jl")
include("2.jl")
include("3.jl")

function calculate_cases()
    workerNum = length(workers())
    expInfo = DataFrame(workers=[],frameSize=[], basic=[],parallel=[],pmap=[],channels=[])

    for i = 0:400:2000
        i = i == 0 ? i + 1 : i

        baseTime = calc_julia_main(2000, 2000)
        parallelTime = calc_julia_main_parallel(2000, 2000)
        pmapTime = calc_julia_main_pmap(2000, 2000, i)
        rChannel = calc_julia_main_rchannel(2000, 2000, i)

        push!(expInfo, [workerNum i baseTime parallelTime pmapTime rChannel])
    end
    expInfo
end

function display_results()
    plots = Vector{Gadfly.Plot}()
    results = calculate_cases()
    push!(plots, Gadfly.plot(results,
                    layer(y = "basic", x = "frameSize", Geom.line,Theme(default_color="green")),
                    layer(y = "parallel", x = "frameSize", Geom.line,Theme(default_color="blue")),
                    layer(y = "pmap", x = "frameSize", Geom.line, Theme(default_color="orange")),
                    layer(y = "channels", x = "frameSize", Geom.line, Theme(default_color="red")),
                    Guide.YLabel("Time[s]"),
                    Guide.manual_color_key("legend", [ "basic", "parallel","pmap","channels"],[ "green", "blue","orange","red"])))
 set_default_plot_size(30cm, 15cm)
 vstack(plots)
end

#addprocs(3)
