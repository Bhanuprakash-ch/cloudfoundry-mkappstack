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

include *.mk
include lib/make/gnumake.mk
include lib/make/osenv.mk
include lib/make/messages.mk
include lib/make/functions.mk
include lib/make/cloudfoundry.mk

clean:
	rm -rf $(LOCALFILES)

cfclean: purge_services purge_applications purge_upsis purge_brokers

wipeall: cfclean clean

discover: $(cfspace)_summary.yml $(cfspace)_upsi.yml $(cfspace)_sbrokers.yml
	$(shmute)lib/ruby/ymlmerge.rb $^ >$@.yml

appstack deploy: deploy_buildpacks deploy_applications deploy_services
	$(shmute)rm -f $(CFOBJFILES)

rebind-apps: rebind_applications

artifact-pack: $(cfspace)_artifacts.tar.gz

