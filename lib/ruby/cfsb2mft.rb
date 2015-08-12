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
# use with output of /v2/service_brokers
# usage cfsb2mft.rb <cf_list_name> <manifest_list_name>

require 'yaml'

cf_list = ARGV.shift || "resources"
manifest_list = ARGV.shift || "service_brokers"

cfobj = YAML::load(STDIN.read)
manifest = Hash.new

manifest[manifest_list] = cfobj[cf_list].map { |sb| {
	"name"		=>	sb["entity"]["name"],
	"broker_url"	=>	sb["entity"]["broker_url"],
	"auth_username"	=>	sb["entity"]["auth_username"]
	}.delete_if {|key,val| !val or val.empty?}
}

puts YAML.dump(manifest)
