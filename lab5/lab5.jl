#1. Harmonic Mean Calc
@generated function harmonic_mean(dims::NTuple{N}) where N
    ex = :(1 / dims[$N])
    for i = N-1:-1:1
        ex = :(1 / dims[$i] + $ex)
    end
    return :($N / $ex)
end

#2. Automatic differentiation
diff_rule(ex::Symbol) = (ex == :x) ? 1 : 0
diff_rule(ex::Expr) = autodiff(ex)
diff_rule(ex) = 0

function expand_expr(ex::Expr)
    N = length(ex.args)

    expA = expand_expr(ex.args[2])
    expB = expand_expr(ex.args[3])
    nEx = Expr(:call, ex.args[1], ex.args[2], ex.args[3])

    for i = 4:N
        expArg = expand_expr(ex.args[i])
        nEx = Expr(:call, ex.args[1], nEx, expArg)
    end

    nEx
end
expand_expr(ex) = ex

function autodiff(ex::Expr)::Expr
    ex = expand_expr(ex)
    if(ex.args[1] == :+)
        a_d = diff_rule(ex.args[2])
        b_d = diff_rule(ex.args[3])

        :($a_d + $b_d)
    elseif(ex.args[1] == :-)
        a_d = diff_rule(ex.args[2])
        b_d = diff_rule(ex.args[3])

        :($a_d - $b_d)
    elseif(ex.args[1] == :*)
        a = ex.args[2]
        b = ex.args[3]
        a_d = diff_rule(a)
        b_d = diff_rule(b)

        :($a * $b_d + $a_d * $b)
    elseif(ex.args[1] == :/)
        a = ex.args[2]
        b = ex.args[3]
        a_d = diff_rule(a)
        b_d = diff_rule(b)

        :(($a_d * $b - $a * $b_d) / ($b * $b))
    else
        Base.error("Unsupported operation.")
    end
end
