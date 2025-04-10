using Revise
using PowerSystems
using PowerSimulations
using Dates
using Logging
using DataFrames
using CSV
using StorageSystemsSimulations
using InfrastructureSystems
logger = configure_logging(console_level=Logging.Info)
const PSI = PowerSimulations
const PSY = PowerSystems
const SS = StorageSystemsSimulations
const IS = InfrastructureSystems
using TimeSeries
using JuMP
using HiGHS
using Gurobi
using Random

Random.seed!(10)
include((@__DIR__)*"/simulation_utils.jl")

### Parsing Args
sys_name = (@__DIR__)*"/../systems_data/5bus_system_PV.json"

interval = 24 # simulation step interval in Hours
num_periods = 1
horizon = 15*24 # total time periods in hours, including the day-ahead time
steps = 350 # number of steps in the simulation
battery = true
form = "StorageDispatch"
network_formulation = "StandardPTDFModel"
output_dir = (@__DIR__)*"/5bus_sims/move_wind_PVcase"

solver = optimizer_with_attributes(
    HiGHS.Optimizer, "output_flag" => false, "mip_rel_gap" => 1e-5, "time_limit" => 10000., "threads" => Threads.nthreads()
)

if !ispath(output_dir)
    mkpath(output_dir)
end

template_uc = get_template_uc(network_formulation, "StorageDispatch")

Wind_rd_dict = Dict("node_a" => String[], "node_b" => ["Wind2"], "node_c" => ["SolarPV1"], "node_d" => String[], "node_e" => ["Wind"])
PV_rd_dict = Dict("node_a" => ["SolarPV3"], "node_b" => String[], "node_c" => ["SolarPV1"], "node_d" => ["SolarPV2"], "node_e" => ["Wind"])

# function takes sim_name, bus (for LDES location), and vre_bus (for new wind location)
function run_new_simulation(sim_name, bus, vre_bus)
    sys_UC = System(sys_name)

    # Move LDES
    ldes = get_component(GenericBattery, sys_UC, "5bus_60_long_duration")

    new_bus = get_component(Bus, sys_UC, bus)

    new_bus_num = new_bus.number
    ldes.bus = new_bus
    ldes.name = "LDES_bus$new_bus_num"

    # Get wind generator from bus 5
    wind = get_component(RenewableDispatch, sys_UC, "Wind")

    wind_ts = get_time_series(SingleTimeSeries, wind, "max_active_power")

    println("MOVING VRE")
    flush(stdout)

    # Move the wind generator from bus 5 to another node
    if vre_bus in ["node_a", "node_c", "node_d"]
        vre_to_switch = get_component(RenewableDispatch, sys_UC, PV_rd_dict[vre_bus][1])
        ts_switch = get_time_series(SingleTimeSeries, vre_to_switch, "max_active_power")

        remove_time_series!(sys_UC, SingleTimeSeries, wind, "max_active_power")
        remove_time_series!(sys_UC, SingleTimeSeries, vre_to_switch, "max_active_power")

        new_vre_bus = get_component(Bus, sys_UC, vre_bus)
        bus5 = get_component(Bus, sys_UC, "node_e")

        wind.bus = new_vre_bus
        vre_to_switch.bus = bus5

        add_time_series!(sys_UC, wind, wind_ts)
        add_time_series!(sys_UC, vre_to_switch, ts_switch)
    else
        new_vre_bus = get_component(Bus, sys_UC, vre_bus)

        wind.bus = new_vre_bus
    end
    println("VRE MOVED")
    flush(stdout)

    set_units_base_system!(sys_UC, PSY.UnitSystem.SYSTEM_BASE)

    # Add forecast errors for simulations
    Random.seed!(10)
    add_single_time_series_forecast_error!(sys_UC, horizon, Hour(interval), 0.05)

    # Define models and simulations
    models = SimulationModels(
        decision_models=[
            DecisionModel(template_uc,
                sys_UC,
                name="UC",
                optimizer=solver,
                initialize_model=false,
                optimizer_solve_log_print=false,
                direct_mode_optimizer=true,
                check_numerical_bounds=false,
                warm_start=true,
            ),
        ],
    )

    sequence = SimulationSequence(
        models=models,
        ini_cond_chronology=InterProblemChronology(),
    )

    sim = Simulation(
        name="$(sim_name)",
        steps=steps,
        models=models,
        sequence=sequence,
        simulation_folder=output_dir,
        # initial_time=DateTime("2024-01-01T00:00:00"),
    )

    build!(sim, console_level=Logging.Info, file_level=Logging.Info)
    model = get_simulation_model(sim, :UC)
    if occursin("RTS", sys_name)
        add_must_run_constraint!(model)
    end

    println("RUNNING SIMULATION")
    flush(stdout)

    exec_time = @elapsed execute!(sim, enable_progress_bar=true, cache_size_mib = 512, min_cache_flush_size_mib = 100)


    results = SimulationResults(sim);
    results_uc = get_decision_problem_results(results, "UC");
    export_results_csv(results_uc, "UC", joinpath(results.path, "results"))
end

buses = ["node_a", "node_b", "node_c", "node_d", "node_e"]

for (i, wind_bus) in enumerate(buses)
    for (ii, ldes_bus) in enumerate(buses)
        run_new_simulation("5bus_PV_ld$(ii)_wind$(i)_PTDF", ldes_bus, wind_bus)
    end
end
