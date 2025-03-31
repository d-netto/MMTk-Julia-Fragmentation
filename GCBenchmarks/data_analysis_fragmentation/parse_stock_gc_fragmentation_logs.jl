using Plots

const STOCK_GC_FRAGMENTATION_PATHS = ["stock_gc_fragmentation_logs.txt"]

# Each line in the logs are of the form:
# `Utilization in pool allocator: 0.131837, 8849600 live bytes and 67125248 bytes in pages`
# Let's exptract utilization and fragmentation data from the logs and plot them as a time series
function parse_stock_gc_fragmentation_logs()
    for path in STOCK_GC_FRAGMENTATION_PATHS
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
        # Plot the data
        plot(
            utilization,
            title="Stock GC Pool Allocator Utilization",
            xlabel="GC Iteration",
            ylabel="Utilization (%X)",
            legend=false,
            grid=true,
        )
        savefig("stock_gc_utilization.png")
        plot(
            fragmentation,
            title="Stock GC Pool Allocator Fragmentation",
            xlabel="GC Iteration",
            ylabel="Fragmentation (MB)",
            legend=false,
            grid=true,
        )
        savefig("stock_gc_fragmentation.png")
    end
end

const MMTK_IMMIX_GC_FRAGMENTATION_PATHS = ["mmtk_sticky_immix_gc_fragmentation_logs.txt"]

# Each line in the logs are of the form:
# `Utilization in space "immix": 33428624 live bytes, 150147072 total bytes, 22.26 %`
# Let's exptract utilization and fragmentation data from the logs and plot them as a time series
function parse_mmtk_sticky_immix_gc_fragmentation_logs()
    for path in MMTK_IMMIX_GC_FRAGMENTATION_PATHS
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
        # Plot the data
        plot(
            utilization,
            title="MMTk Immix GC Utilization",
            xlabel="GC Iteration",
            ylabel="Utilization (%X)",
            legend=false,
            grid=true,
        )
        savefig("mmtk_sticky_immix_utilization.png")
        plot(
            fragmentation,
            title="MMTk Immix GC Fragmentation",
            xlabel="GC Iteration",
            ylabel="Fragmentation (MB)",
            legend=false,
            grid=true,
        )
        savefig("mmtk_sticky_immix_fragmentation.png")
    end
end

parse_stock_gc_fragmentation_logs()
parse_mmtk_sticky_immix_gc_fragmentation_logs()
