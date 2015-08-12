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

# accepts cf space summary JSON at STDIN
# use with output of /v2/spaces/:space_guid/summary
# usage cfspace2mft.rb space_summary.json services.json service_brokers.json

require 'yaml'

def getBrokerNameBySvcLabel(svclabel, services_obj, service_brokers_obj)
  cf_generic_list = "resources"

  service_broker_guid = services_obj[cf_generic_list].find {
    |svc| svc["entity"]["label"] == svclabel
  }["entity"]["service_broker_guid"]

  service_broker_name = service_brokers_obj[cf_generic_list].find {
    |sb| sb["metadata"]["guid"] == service_broker_guid
  }["entity"]["name"]

  return service_broker_name
end

space_summary = ARGV.shift
services = ARGV.shift
service_brokers = ARGV.shift

cf_app_list = "apps"
manifest_app_list = "applications"
cf_svci_list = "services"
manifest_svci_list = "service_instances"

space_obj = YAML::load(File.open(space_summary))
svc_obj = YAML::load(File.open(services))
sbk_obj = YAML::load(File.open(service_brokers))
manifest = Hash.new


manifest[manifest_app_list] = space_obj[cf_app_list].map { |app| {
	"name"		=>	app["name"],
	"buildpack"	=>	app["buildpack"],
	"command"	=>	app["command"],
	"disk_quota"	=>	app["disk_quota"].to_s + "M",
	"domains"	=>	app["routes"].empty? ? nil : app["routes"].map { |route| route["domain"]["name"] },
	"env"		=>	app["environment_json"].empty? ? nil : app["environment_json"],
	"hosts"		=>	app["routes"].empty? ? nil : app["routes"].map { |route| route["host"] },
	"instances"	=>	app["instances"],
	"memory"	=>	app["memory"].to_s + "M",
	"services"	=>	app["service_names"].empty? ? nil : app["service_names"],
	"timeout"	=>	app["health_check_timeout"]
	}.delete_if { |key,val| !val }
}

manifest[manifest_svci_list] = space_obj[cf_svci_list].select {|svci| svci.has_key?("service_plan")}.map { |svci| {
	"name"		=>	svci["name"],
	"service_plan"	=>	{
		"name"		=>	svci["service_plan"]["name"],
		"service"	=>	{
			"label"		=>	svci["service_plan"]["service"]["label"],
			"broker"	=>	getBrokerNameBySvcLabel(svci["service_plan"]["service"]["label"], svc_obj, sbk_obj),
			"provider"	=>	svci["service_plan"]["service"]["provider"],
			"version"	=>	svci["service_plan"]["service"]["version"]
			}.delete_if {|key,val| !val or val.empty?}
		} 
	}.delete_if {|key,val| !val or val.empty?}
}

puts YAML.dump(manifest)
