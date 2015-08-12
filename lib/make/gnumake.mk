# GNU Make related setup
# Copyright (c) 2015 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SHELL := /bin/bash
devnull := >/dev/null 2>&1
runlog := >>$(cfspace).log 2>&1
comma:=,

ifdef TRACE
  shmute =
  nulout =
else
  shmute = @
  nulout = $(runlog)
endif

.PRECIOUS: %/.dir

.INTERMEDIATE: $(cfspace)_summary.json $(cfspace)_services.json $(cfspace)_sbrokers.json $(cfspace)_upsi.json $(cfspace)_summary.yml $(cfspace)_services.yml $(cfspace)_sbrokers.yml $(cfspace)_upsi.yml

MAKEFILE_TARGETS_WITHOUT_INCLUDE = wipeall clean cfclean deleteapps deletesvcs cfset discover test artifact-pack

