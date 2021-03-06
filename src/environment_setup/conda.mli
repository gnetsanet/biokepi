open Biokepi_run_environment

type python_version_type = [
  | `Python_2
  | `Python_3
  | `Python_custom of string
  | `Python_tool_dependency of string
]

type conda_version_type = [
  | `Latest
  | `Version of string
]

type conda_environment_type = private {
  name: string; (* name of the environment *)
  python_version: python_version_type;
  channels: string list; (* supported installation channels *)
  base_packages: (string * conda_version_type) list; (* defualt installations *)
  banned_packages: string list; (* packages to be removed after initial setup *)
  install_path: string; (* where to install the conda and environments *)
  main_subdir: string; (* subdir that will contain conda utilities *)
  envs_subdir: string; (* subdir that will contain the environment files *)
}

(** Helper method to configure conda environments for tools *)
val setup_environment :
  ?custom_channels: string list ->
  ?base_packages: (string * conda_version_type) list ->
  ?banned_packages: string list ->
  ?main_subdir: string ->
  ?envs_subdir: string ->
  ?python_version: python_version_type ->
  string ->
  string ->
  conda_environment_type

(** A workflow node to make sure that Conda is configured. *)
val configured :
  conda_env: conda_environment_type ->
  run_program: Machine.Make_fun.t ->
  host: Common.KEDSL.Host.t ->
  < is_done : Common.KEDSL.Condition.t option > Common.KEDSL.workflow_node

(** A transform to run Programs with the Conda enviroment activated. *)
val init_env : 
  conda_env: conda_environment_type -> 
  unit -> 
  Common.KEDSL.Program.t

(** A transform to deactivate the conda environment if it is already active *)
val deactivate_env : 
  conda_env: conda_environment_type -> 
  unit -> 
  Common.KEDSL.Program.t

(** This is the absolute path to the environment folder **)
val environment_path : 
  conda_env: conda_environment_type -> 
  string

(** A helper method to construct expected path of a binary (command)
    given a conda environment **)
val bin_in_conda_environment :
  conda_env: conda_environment_type ->
  string ->
  string
