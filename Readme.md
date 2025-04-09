## LDES Sizing and Siting Model

This repository contains code and data for performing a siting analysis of long-duration energy storage (LDES) in the 5-bus and RTS systems using the [Sienna suite](https://github.com/NREL-Sienna) developed by the National Renewable Energy Laboratory for production cost modeling (PCM). It corresponds to software record SWR-25-75. This analysis involves moving the LDES component to different buses in the system, running a simulation, and considering the production cost of the simulation. Different system configurations are also analyzed with these scripts (such as moving load or renewable dispatch generators to different buses) to observe the impacts the system configuration has on optimal siting. This repository contains three sub directories discussed below. Both the 5-bus and RTS systems have two different initial configurations for the renewable energy components in them, one that is predominantly PV-driven and one that is predominantly wind-driven.


| System | Total Load (GWh) | Total VRE (GWh) | Total PV (GWh) | Total Wind (GWh)| VRE Cap. (GW) | PV Cap. (GW) | Wind Cap. (GW)|
| ----- | ----- |  ----- |  ----- |  ----- |  ----- | ----- | ----- |
|5-bus (PV-Driven) | 5,780 | 4,180| 2,460| 1,720| 1.57 | 1.12 | 0.45 |
|5-bus (Wind-Driven) | 5,780 | 6,040 | 1,640 | 4,400| 1.90 | 0.75 | 1.15 | 
|RTS (PV-Driven) | 37,650 | 32,980 | 23,340 | 9,640 | 12.85 | 9.54 | 3.31 |
|RTS (WInd-Driven) | 37,650 | 42,880 | 11,400 | 31,480| 15.95 | 4.61 | 11. 33 |

| System | # Loads | # PV | # Wind | # Thermal | # Lines | # Tap Transformer
| ----- | ----- |  ----- |  ----- |  ----- |  ----- | ----- |
|5-bus (PV-Driven) | 3 | 3 | 1 |2 |6 |0|
|5-bus (Wind-Driven) | 3 | 1 | 2| 2| 6 | 0|
|RTS (PV-Driven) | 51 | 58 | 5 | 54 | 105 | 15|
|RTS (WInd-Driven) | 51 | 29 | 18 | 54 | 105 | 15 |

| SDES | Size (MWh) | Max Charge (MW) | Max Discharge (MW) | Charge Efficiency | Discharge Efficiency | Duration (hr) |
| ----- | ----- |  ----- |  ----- |  ----- |  ----- | ----- |
|5-bus (PV-Driven) | 640 | 160 | 160| 0.85 | 1.0 | 3.6 |
|5-bus (Wind-Driven) | 1,000 | 250 | 250 | 0.85 | 1.0 | 3.6 |
|RTS (PV-Driven) | 4,000 | 1,000 | 1,000 | 0.85 | 1.0 | 3.6 |
|RTS (WInd-Driven) | 6,000 | 1,500 | 1,500 | 0.85 | 1.0 | 3.6 |

| LDES | Size (MWh) | Max Charge (MW) | Max Discharge (MW) | Charge Efficiency | Discharge Efficiency | Duration (hr) |
| ----- | ----- |  ----- |  ----- |  ----- |  ----- | ----- |
|5-bus (PV-Driven) |5,700 | 380 | 380 | 0.7 | 1.0 | 13.5 | 
|5-bus (Wind-Driven) | 9,000 | 600 | 600 | 0.7 | 1.0 | 13.5 |
|RTS (PV-Driven) | 60,000 | 4,000 | 4,000 | 0.7 | 1.0 | 13.5 |
|RTS (WInd-Driven) | 49,500 | 3,300 | 3,300 | 0.7 | 1.0 | 13.5|


Note that these systems also have a lower bound on the state of charge (at 10%) of the storage systems, and this is reflected in the duration. In other words, the duration is equal to 90% of the size divided by the discharge.

### `systems_data/`
This directory contains the system data for the 5-bus and RTS systems (both PV- and wind-driven) under the names `5_bus_system_PV.json`, `5_bus_system_Wind_caseB.json`, `RTS_system_PV_caseA.json`, and `RTS_system_Wind_caseB.json`.

### `scripts/`

The following Julia scripts are contained in this directory. Note that the 5-bus scripts are specific to the Wind-driven case, but they can be adapted to work with the PV driven case: 
 * `simulation_utils.jl` - contains functions used in the simulations, such as the UC template used for Sienna simulations.
 * `MultiStage_5bus_move_wind.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also moving the wind generator (originally on Bus 5) to different buses to determine the impact of VRE placement on optimal LDES placement.
 * `MultiStage_5bus_move_aggVRE.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also placing all VRE generators on a single bus to determine the impact of VRE concentration and placement on optimal LDES placement.
 * `MultiStage_5bus_move_loads.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also moving the largest load (originallyl on Bus 4) to different buses to determine the impact of load on optimal LDES placement.
 * `MultiStage_5bus_move_SDES.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also moving the SDES(originallyl on Bus 1) to different buses to determine the impact of SDES location on optimal LDES placement.
 * `MultiStage_5bus_reduce_line_capacity.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also decreasing the transmission capacity on all lines by the same percent reduction to determine impact of transmission constraints on LDES siting. 
 * `MultiStage_5bus_reduce_thermal_capacity.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also decreasing the thermal standard peak capacity to determine how storage impacts required peaking capacity of thermal generators. 
 * `MultiStage_5bus_test_horizon_impacts.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) and using different simulation horizons. 
 * `MultiStage_5bus_move_wind_PVcase.jl` - Contains code for moving the LDES component to a different bus in the system (to determine optimal placement) while also moving the wind generator (originally on Bus 5) to different buses to determine the impact of VRE placement on optimal LDES placement, but, unlike the other `move_wind` file, this is for a PV-driven case. 
 * `MultiStage_RTS.jl` - Contains code for simulating the RTS system with LDES. The LDES component can be moved to different buses in the system. 
 * `read_solutions.jl` - Contains code for loading solutions of a simulation and determining different metrics/descriptors for the system. Note that a simulation must first be run and saved before running this script as no simulations are stored directly in this repository.
 * `template_functions.jl` - Contains the functions called by `read_solutions.jl`.

To run a given script without LDES contained in the simulation, the user can pass `false` as the third argument of the `get_template_uc` function. In addition, look-ahead horizons can be altered for any of these simulations by changing the `horizon` parameter in the scripts. 

### `packages/`
Two of the packages in the `Project.toml` file were modified slightly from the original package versions, and these changes are captured in this directory. The StorageSystemsSimulations.jl version used for our simulations can be found in this directory and marked for development. The PowerSimulations.jl package is slightly modified, but corresponds very closely to PowerSimulations.jl version 0.19.6 (commit [4fbe86e](https://github.com/NREL-Sienna/PowerSimulations.jl/tree/4fbe86efb1a9f7fa2cc7026e3b1681e216dc472a)), and for the time horizon comparison scripts and 5-bus PV-driven case, version 0.19.6 was directly used. 

### `env/`
This directory contains the environment for running the above scripts. This environment can be activated and then instantiated to get access to the required packages. To activate and instantiate a Julia environment, a user can go to the Julia REPL, type `]` to enter the package manager and then type `activate path_to_env_directory/`, hit enter, and then type `instantiate`. Note that we used Julia 1.9.2 for the simulations, and other versions of Julia may not instantiate without error. The exact package versions we used can also be accessed in the file `env/Manifest.toml`. 
