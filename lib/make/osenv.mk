# OS environment related setup
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

ruby = ruby -ryaml -rjson -e
curlcmd = curl -f -k -L
unzip = unzip -q -o -DD

bpkdir = bpks
appdir = apps
svidir = svci
svcdir = svcs
sbkdir = sbks
upsdir = upsi
srcdir = artifacts
bscdir = buildpacks
artifactspack = $(cfspace)_artifacts.tar.gz
 
LOCALFILES = $(bpkdir) $(appdir) $(svidir) $(svcdir) $(sbkdir) $(upsdir) $(srcdir) $(artifactspack)

.PRECIOUS: $(srcdir)/%.zip

ifeq (,$(shell which ruby))
  $(error "No ruby in $(PATH), consider doing apt-get install ruby")
endif
ifneq (2,$(shell ruby -e 'puts RUBY_VERSION.split(".")[0]'))
  $(error "Ruby major version >=2 not detected")
endif
ifneq (,$(shell ruby -e 'begin require "yaml"; rescue LoadError => e; puts e; end'))
  $(error "No ruby YAML module available, consider installing one")
endif
ifneq (,$(shell ruby -e 'begin require "json"; rescue LoadError => e; puts e; end'))
  $(error "No ruby JSON module available, consider installing one")
endif

%/.dir:
	$(info $(call i_dircrte,$(@D)))
	$(shmute)mkdir -p $(@D)
	$(shmute)touch $@
