using Plots

const STOCK_GC_FRAGMENTATION_PATHS = ["logs/fragmentation_benchmark_julia-stock.log", "logs/inference_benchmark_julia-stock.log"]

# Each line in the logs are of the form:
# `Utilization in pool allocator: 0.131837, 8849600 live bytes and 67125248 bytes in pages`
# Let's exptract utilization and fragmentation data from the logs and plot them as a time series
function parse_stock_gc_fragmentation_logs()
    for path in STOCK_GC_FRAGMENTATION_PATHS
        # Whether we're running the fragmentation benchmark or the inference benchmark
        fragmentation_benchmark = false
        if occursin("fragmentation_benchmark", path)
            fragmentation_benchmark = true
        else
            # inference benchmark...
        end
        # Read the file
        lines = readlines(path)
        # Extract the utilization and fragmentation data
        utilization = Float64[]
        fragmentation = Float64[]
        for line in lines
            if occursin("Utilization in pool allocator", line)
                # The first parameter of match is the regex pattern, the second is the string to match
                push!(utilization, 100.0 * parse(Float64, match(r"([0-9]+.[0-9]+)", line)[1]))
                # Fragmentation is `bytes in pages - `live bytes``
                # E.g. in the line ``Utilization in pool allocator: 0.131837, 8849600 live bytes and 67125248 bytes in pages`,
                # it is `67125248 - 8849600`
                # The first parameter of match is the regex pattern, the second is the string to match
                live_bytes = parse(Int, match(r"([0-9]+) live bytes", line)[1])
                pages_bytes = parse(Int, match(r"([0-9]+) bytes in pages", line)[1])
                fragmentation_in_mb = (pages_bytes - live_bytes) / 1024 / 1024
                push!(fragmentation, fragmentation_in_mb)
            end
        end
        # Plot the utilization data
        plot(
            utilization,
            title="Stock GC Pool Allocator Utilization",
            xlabel="GC Iteration",
            ylabel="Utilization (%X)",
            legend=false,
            grid=true,
        )
        file_name = fragmentation_benchmark ? "stock_gc_fragmentation_benchmark_utilization.png" : "stock_gc_inference_benchmark_utilization.png"
        savefig(file_name)
        # Plot the fragmentation data
        plot(
            fragmentation,
            title="Stock GC Pool Allocator Fragmentation",
            xlabel="GC Iteration",
            ylabel="Fragmentation (MB)",
            legend=false,
            grid=true,
        )
        file_name = fragmentation_benchmark ? "stock_gc_fragmentation_benchmark_fragmentation.png" : "stock_gc_inference_benchmark_fragmentation.png"
        savefig(file_name)
    end
end

const MMTK_GC_FRAGMENTATION_PATHS = ["logs/fragmentation_benchmark_julia-immix-moving-upstream.log",
    "logs/inference_benchmark_julia-immix-moving-upstream.log"]

# Each line in the logs are of the form:
# `Utilization in space "immix": 33428624 live bytes, 150147072 total bytes, 22.26 %`
# Let's exptract utilization and fragmentation data from the logs and plot them as a time series
function parse_mmtk_gc_fragmentation_logs()
    for path in MMTK_GC_FRAGMENTATION_PATHS
        # Whether we're running the fragmentation benchmark or the inference benchmark
        fragmentation_benchmark = false
        if occursin("fragmentation_benchmark", path)
            fragmentation_benchmark = true
        else
            # inference benchmark...
        end
        # Whether the GC is generational or not
        sticky = false
        if occursin("sticky", path)
            sticky = true
        end
        # Read the file
        lines = readlines(path)
        # Extract the utilization and fragmentation data
        utilization = Float64[]
        fragmentation = Float64[]
        for line in lines
            if occursin("Utilization in space \"immix\"", line)
                # The first parameter of match is the regex pattern, the second is the string to match
                push!(utilization, parse(Float64, match(r"([0-9]+.[0-9]+) %", line)[1]))
                # Fragmentation is `total bytes - `live bytes``
                # E.g. in the line ``Utilization in space "immix": 33428624 live bytes, 150147072 total bytes, 22.26 %`,
                # it is `150147072 - 33428624`
                # The first parameter of match is the regex pattern, the second is the string to match
                live_bytes = parse(Int, match(r"([0-9]+) live bytes", line)[1])
                total_bytes = parse(Int, match(r"([0-9]+) total bytes", line)[1])
                fragmentation_in_mb = (total_bytes - live_bytes) / 1024 / 1024
                push!(fragmentation, fragmentation_in_mb)
            end
        end
        # Plot the utilization data
        gc_name = sticky ? "MMTk Sticky Immix" : "MMTk Immix"
        plot(
            utilization,
            title="$gc_name Utilization (IMMIX space)",
            xlabel="GC Iteration",
            ylabel="Utilization (%X)",
            legend=false,
            grid=true,
        )
        local utilization_file_name
        if fragmentation_benchmark
            utilization_file_name = sticky ? "mmtk_sticky_immix_fragmentation_benchmark_utilization.png" : "mmtk_immix_fragmentation_benchmark_utilization.png"
        else
            utilization_file_name = sticky ? "mmtk_sticky_immix_inference_benchmark_utilization.png" : "mmtk_immix_inference_benchmark_utilization.png"
        end
        savefig(utilization_file_name)
        # Plot the fragmentation data
        plot(
            fragmentation,
            title="$gc_name Fragmentation (IMMIX space)",
            xlabel="GC Iteration",
            ylabel="Fragmentation (MB)",
            legend=false,
            grid=true,
        )
        local fragmentation_file_name
        if fragmentation_benchmark
            fragmentation_file_name = sticky ? "mmtk_sticky_immix_fragmentation_benchmark_fragmentation.png" : "mmtk_immix_fragmentation_benchmark_fragmentation.png"
        else
            fragmentation_file_name = sticky ? "mmtk_sticky_immix_inference_benchmark_fragmentation.png" : "mmtk_immix_inference_benchmark_fragmentation.png"
        end
        savefig(fragmentation_file_name)
    end
end

parse_stock_gc_fragmentation_logs()
parse_mmtk_gc_fragmentation_logs()
