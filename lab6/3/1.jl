using Plots
Plots.gr()

@everywhere function generate_julia(z; c=2, maxiter=200)
    for i=1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    maxiter
end

@everywhere function calc_julia_parallel!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
   @sync @parallel for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end

@everywhere function calc_julia_main_parallel(h,w)
   xmin, xmax = -2,2
   ymin, ymax = -1,1
   xrange = linspace(xmin, xmax, w)
   yrange = linspace(ymin, ymax, h)
   #println(xrange[100],yrange[101])
   julia_set = SharedArray{Int64}(w, h)
   eTime = @elapsed calc_julia_parallel!(julia_set, xrange, yrange, height=h, width_end=w)

   Plots.heatmap(xrange, yrange, julia_set)
   png("julia")
   eTime
end


#calc_julia_main(2000,2000)
