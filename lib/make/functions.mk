# GNU Make functions setup
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

r_ymlcmpr = $(ruby) 'exit YAML::load(File.open("$(1)"))==YAML::load(File.open("$(2)"))'
r_ymllistdo = $(ruby) 'YAML.load(STDIN.read)["$(1)"].each { $(2) }'
r_ymllistelemval = $(ruby) 'puts YAML.load(STDIN.read)["$(1)"].uniq.find { $(2) }$(3)'
r_ymllistelemvaljson = $(ruby) 'puts JSON.dump(YAML.load(STDIN.read)["$(1)"].uniq.find { $(2) }$(3))'
r_appgetattr = $(call r_ymllistelemval,$(yml_appseq),|app| app["name"]=="$(1)",$(2))
r_svigetdep = $(call r_ymllistelemval,$(yml_sviseq),|svi| svi["name"]=="$(1)",["service_plan"]["service"]["label"])
r_svcgetdep = $(call r_ymllistelemval,$(yml_sviseq),|svi| svi["service_plan"]["service"]["label"]=="$(1)",["service_plan"]["service"]["broker"])
#r_ymlGetLstElemByNamedVal = $(ruby) 'puts YAML.dump(Hash["$(1)",[YAML.load(STDIN.read)["$(1)"].find { |elem| elem["$(2)"]=="$(3)" }.sort.to_h]])'
r_ymlGetLstElemByNamedVal = $(ruby) 'puts YAML.dump(Hash["$(1)",[YAML.load(STDIN.read)["$(1)"].find { |elem| elem["$(2)"]=="$(3)" }]])'

