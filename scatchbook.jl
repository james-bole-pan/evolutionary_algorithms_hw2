function replace_subexpr!(main_expr, old_subexpr, new_subexpr)
    if main_expr == old_subexpr
        return new_subexpr
    end

    for i in 1:length(main_expr.args)
        if main_expr.args[i] == old_subexpr
            main_expr.args[i] = new_subexpr
        elseif isa(main_expr.args[i], Expr)
            main_expr.args[i] = replace_subexpr!(deepcopy(main_expr.args[i]), old_subexpr, new_subexpr)
        end
    end
    
    return main_expr
end

main_expr = :(7.434864366907362(x+x))
old_subexpr = :(x + x)
new_subexpr = :(sin(5.643655498881259 / (7.434864366907362x) + (x + x)))
replace_subexpr!(main_expr, old_subexpr, new_subexpr)
println("main_expr: ", main_expr)