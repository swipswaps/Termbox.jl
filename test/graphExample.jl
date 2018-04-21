# Simple updating graph example
module UpdatingGraph

using Termbox
using Compat
if VERSION < v"0.6-"
    exit(0)
end
if VERSION >= v"0.7-"
    using Random
    using Printf
end

# Termbox GUI
function putchar(k, i, c)
    tb_change_cell(k, i, c, 0x0001, 0x0000)
end

#TODO: Refactor interface below into boxes
function tb_print(g::BitMatrix)
    tb_clear()
    n, m = size(g)
    for row in 1:n
        for col in 1:m
            g[row, col] && putchar(col, row, '#')
        end
    end    
    tb_present()
end

function main_loop_random(maxSteps::Integer = 100, numTrue = 15)
    g = falses(tb_width(), tb_height())
    g[shuffle(eachindex(g))[1:numTrue]] = true
    steps = 0

    tb_print(g)
    while (steps < maxSteps)
        g[shuffle(eachindex(g))[1:numTrue]] = true
        tb_print(g)
        sleep(0.01)
        steps += 1
    end
end

function main_loop_waterfall(maxSteps::Integer = 100, numTrue = 15)
    nc = tb_width()
    nr = tb_height()
    g = falses(nr, nc)
    steps = 0

    tb_print(g)
    while (steps < maxSteps)
        for col in 1:(nc-1)
            for row in 1:nr
                g[row, col] = g[row, col + 1]
            end
        end
        g[rand(1:nr), nc] = true
        tb_print(g)
        sleep(0.01)
        steps += 1
    end
end

function main_loop_randomgraph(maxSteps::Integer = 200, numTrue = 15)
    nc = tb_width()
    nr = tb_height()
    g = falses(nr, nc)
    steps = 0

    tb_print(g)
    while (steps < maxSteps)
        for col in 1:(nc-1)
            for row in 1:nr
                g[row, col] = g[row, col + 1]
                g[row, col + 1] = false
            end
        end
        g[rand(1:nr), nc] = true
        tb_print(g)
        sleep(0.05)
        steps += 1
    end
end

function main_loop(maxSteps::Integer = 200, numTrue = 15)
    nc = tb_width()
    nr = tb_height()
    g = falses(nr, nc)
    steps = 0
    tau = 1e-1

    tb_print(g)
    while (steps < maxSteps)
        for col in 1:(nc-1)
            for row in 1:nr
                g[row, col] = g[row, col + 1]
                g[row, col + 1] = false
            end
        end
        g[floor(Int, (nr/2)*(sin(steps*tau) + 1))+1, nc] = true
        tb_print(g)
        sleep(0.01)
        steps += 1
    end
end
function main()
    ret = tb_init()
    if ret != 0
        @printf stderr "tb_init() failed with error code %d\n" ret
        return 1
    end

    try
        tb_clear()
        tb_select_input_mode(TB_INPUT_ESC)
        tb_select_output_mode(TB_OUTPUT_NORMAL)

        main_loop() # or main_loop_randomgraph, or main_loop_waterfall, or main_loop_random
    finally
        tb_shutdown()
    end
    return 0
end

end # module

# To see the demo, run
# julia -L graphExample.jl -e 'UpdatingGraph.main()'
# The latter command is suitable for iteration on the code itself.