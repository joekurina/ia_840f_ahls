#!/bin/bash
# attempt0: read-only probe of qsys-script/qsys-generate 26.1.1 API
set -x
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export LM_LICENSE_FILE="$HOME/quartus_26/LR-191011_License.dat"
export PATH="/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/sopc_builder/bin:/opt/altera/26.1.1/qsys/bin:$PATH"
SCRATCH=/home/uwb_student00/ahls/new_BSP/work_ahls_qsys_import_01

which qsys-script qsys-generate quartus_sh
sha256sum /opt/altera/26.1.1/qsys/bin/qsys-script /opt/altera/26.1.1/qsys/bin/qsys-generate
qsys-script --version
echo ====QSYS_SCRIPT_HELP====
qsys-script --help
echo ====QSYS_GENERATE_HELP====
qsys-generate --help
echo ====TCL_PROC_PROBE====
mkdir -p "$SCRATCH/probe" && cd "$SCRATCH/probe"
qsys-script --package-version=26.1 --cmd='puts "PROBE:interp-ok"; foreach p {create_system load_component load_components load_system save_component save_system add_instance add_connection add_interface set_interface_property validate validate_component_footprint reload_component_footprint sync_sysinfo_parameters} { puts "PROBE:$p=[llength [info commands $p]]" }; if {[catch {set h [help load_component]}]} { puts "PROBE:help-load_component-unavailable" } else { puts $h }; puts "PROBE:DONE"'
echo PROBE_RC=$?
echo QSYSIMP_DONE_PROBE
