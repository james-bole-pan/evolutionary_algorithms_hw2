function replace_subexpr!(main_expr, old_subexpr, new_subexpr)
    if main_expr == old_subexpr
        return new_subexpr
    end

    for i in 1:length(main_expr.args)
        if main_expr.args[i] == old_subexpr
            main_expr.args[i] = new_subexpr
        elseif isa(main_expr.args[i], Expr)
            replace_subexpr!(main_expr.args[i], old_subexpr, new_subexpr)
        end
    end
    
    return main_expr
end

main_expr = Expr(:call, :+, :(x+x), :x)
old_subexpr = :x
new_subexpr = Expr(:call, :-, :x, 1)
replace_subexpr!(main_expr, old_subexpr, new_subexpr)
println("main_expr: ", main_expr)