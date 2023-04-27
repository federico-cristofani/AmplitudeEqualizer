function compute_max_frequency(target_clock::Float64, setup_slacks::Vector{Float64})
    frequencies::Vector{Float64} = []
    for slack in setup_slacks
        push!(frequencies, target_clock - slack)
    end
    return @.round(1 / frequencies / 10^6, digits = 2)
end

println(compute_max_frequency(20e-9, [1.133,4.495,4.485,4.523, 9.764]*10^-9))