## LDES Sizing and Siting Model

This repository contains code and data for performing a siting analysis of long-duration energy storage (LDES) in the 5-bus and RTS systems using the [Sienna suite](https://github.com/NREL-Sienna) developed by the National Renewable Energy Laboratory for production cost modeling (PCM). This analysis involves moving the LDES component to different buses in the system, running a simulation, and considering the production cost of the simulation. Different system configurations are also analyzed with these scripts (such as moving load or renewable dispatch generators to different buses) to observe the impacts the system configuration has on optimal siting. This repository contains three sub directories discussed below. Both the 5-bus and RTS systems have two different initial configurations for the renewable energy components in them, one that is predominantly PV-driven and one that is predominantly wind-driven.


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
 * `MultiStage_RTS.jl` - Contains code for simulating the RTS system with LDES. The LDES component can be moved to different buses in the system. 
 * `read_solutions.jl` - Contains code for loading solutions of a simulation and determining different metrics/descriptors for the system. Note that a simulation must first be run and saved before running this script as no simulations are stored directly in this repository.
 * `template_functions.jl` - Contains the functions called by `read_solutions.jl`.


### `packages/`
Two of the packages in the `Project.toml` file were modified slightly from the original package versions, and these changes are captured in this directory. The StorageSystemsSimulations.jl version used for our simulations can be found in this directory and marked for development. The PowerSimulations.jl package is larger in size and so is not directly provided here, but we include the `src/` folder for that package that contains any minor changes we made. A user can clone the PowerSimulations.jl repository for version 0.19.6 (commit [4fbe86e](https://github.com/NREL-Sienna/PowerSimulations.jl/tree/4fbe86efb1a9f7fa2cc7026e3b1681e216dc472a)) and replace the `src/` folder in the cloned repo with the `PowerSimulations.jl/src` folder contained in this subdirectory and then park that for development. 

### Other Information
In addition to these subdirectories, there is also a file called `Project.toml` which contains a list of the packages and their versions used for the simulations. 
