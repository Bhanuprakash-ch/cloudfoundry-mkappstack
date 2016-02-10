# output messages setup
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

i_dircrte = [$(stackpfx)] ----->[dir] create: $(1)
i_cfdwnld = [$(stackpfx)] ««««««[cli] download
i_cfunzip = [$(stackpfx)] ..ooOO[cli] binary uncompress
i_cflogin = [$(stackpfx)] -{ok}-[cli] authenticated: $(1)
i_domcrte = [$(stackpfx)] -»-»-»[dom] create: $(1)
i_apppush = [$(stackpfx)] -»-»-»[app] push application: $(1)
i_appcrmf = [$(stackpfx)] ->->->[app] create manifest: $(1)
i_apprstg = [$(stackpfx)] --»«--[app] restage application: $(1)
i_appnchg = [$(stackpfx)] ======[app] up to date: $(1)
i_appdnld = [$(stackpfx)] ««««««[app] download artifact: $(1)
i_appdler = [$(stackpfx)] ERROR [app] FAILED to download artifact: $(1)
i_appunzp = [$(stackpfx)] ..ooOO[app] uncompress artifact: $(1)
i_appdele = [$(stackpfx)] xxxxxx[app] delete application: $(1)
i_sbkcrte = [$(stackpfx)] -»-»-»[sbk] create service-broker: $(1)
i_sbkupdt = [$(stackpfx)] --»«--[sbk] update service-broker: $(1)
i_sbkdele = [$(stackpfx)] xxxxxx[sbk] delete service-broker: $(1)
i_svccrte = [$(stackpfx)] -»-»-»[svc] create service-offering: $(1)
i_svcdele = [$(stackpfx)] xxxxxx[svc] delete service-offering: $(1)
i_svicrte = [$(stackpfx)] -»-»-»[svi] create service-instance: $(1)
i_sviupdt = [$(stackpfx)] --»«--[svi] update service-instance: $(1)
i_svidele = [$(stackpfx)] xxxxxx[svi] delete service-instance: $(1)
i_upscrte = [$(stackpfx)] -»-»-»[ups] create user-provided-service: $(1)
i_upsupdt = [$(stackpfx)] --»«--[ups] update user-provided-service: $(1)
i_upsdele = [$(stackpfx)] xxxxxx[ups] delete user-provided-service: $(1)
i_bpkcrte = [$(stackpfx)] -»-»-»[bpk] create buildpack: $(1)
i_bpkupdt = [$(stackpfx)] --»«--[bpk] update buildpack: $(1)
i_bpknchg = [$(stackpfx)] ======[bpk] up to date: $(1)
i_bpkdnld = [$(stackpfx)] ««««««[bpk] download buildpack: $(1)
i_bpkdler = [$(stackpfx)] ERROR [bpk] FAILED to download buildpacks: $(1)
