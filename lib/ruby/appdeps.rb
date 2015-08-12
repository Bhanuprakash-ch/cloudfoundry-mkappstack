#!/usr/bin/env ruby
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

# usage appdeps.rb app_manifest.yml appstack_manifest.yml svidir upsdir

require 'yaml'

def getAppDepByDepname(depname, appstack_obj, svidir, upsdir)

  manifest_svci_list = "service_instances"
  manifest_upsi_list = "user_provided_service_instances"

  if appstack_obj[manifest_svci_list].any? { |svci| svci["name"] == depname }
    dep = svidir + "/" + depname + "/.svi"
  elsif appstack_obj[manifest_upsi_list].any? { |upsi| upsi["name"] == depname }
    dep = upsdir + "/" + depname + "/.ups"
  else
    dep = nil
  end

  return dep
end

appmanifest = ARGV.shift
appstackmanifest = ARGV.shift
svidir = ARGV.shift
upsdir = ARGV.shift

manifest_app_list = "applications"
manifest_sbk_list = "service_brokers"

app_obj = YAML::load(File.open(appmanifest))
appstack_obj = YAML::load(File.open(appstackmanifest))

deps = Array.new

if app_obj[manifest_app_list][0].include?("services") and app_obj[manifest_app_list][0]["services"].kind_of?(Array)
  app_obj[manifest_app_list][0]["services"].each {|svcname| deps.push(getAppDepByDepname(svcname, appstack_obj, svidir, upsdir))}
end

puts deps * " "
