# Copyright 2017 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if (ADD_LOGIC_INCLUDED)
    return()
endif()

set(ADD_LOGIC_INCLUDED TRUE)

include(AddThreads)
include(AddGnuCompiler)
include(AddMsvcCompiler)
include(AddClangCompiler)
include(AddVivadoProject)
include(AddQuartusProject)
include(AddHDL)
include(AddStdOVL)

find_package(SVUnit)
find_package(ModelSim)
find_package(NaturalDocs)
find_package(SystemC REQUIRED COMPONENTS SCV UVM)
find_package(Verilator)
find_package(Vivado)
find_package(Quartus)
find_package(GTest)
find_package(StdOVL)

if (SVUNIT_FOUND)
    add_hdl_source(${SVUNIT_HDL_PACKAGE}
        LIBRARY svunit
        SYNTHESIZABLE FALSE
        INCLUDES ${SVUNIT_INCLUDE_DIR}
    )
endif()

if (QUARTUS_FOUND)
    add_hdl_source(${QUARTUS_MEGA_FUNCTIONS}
        LIBRARY intel-sim
        SYNTHESIZABLE FALSE
        VERILATOR_CONFIGURATIONS
            "lint_off -file \"${QUARTUS_MEGA_FUNCTIONS}\""
            "lint_off -msg STMTDLY -file \"${QUARTUS_MEGA_FUNCTIONS}\""
    )

    set(HDL_DEPENDS ${HDL_DEPENDS} altera_mf)
endif()
