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

# compares 2 single-app YAML manifests
# usage appmftcompare.rb <app1_mft_path> <app2_mft_path>

require 'yaml'

compare_keys = [
  "name",
  "buildpack",
  "command",
  "disk_quota",
  "domains",
  "env",
  "hosts",
  "instances",
  "memory",
  "services",
  "timeout"
]

app1path = ARGV.shift || "app1.yml"
app2path = ARGV.shift || "app2.yml"

def sanitize(yml, compare_keys)
  sane = yml
  if sane.class == Hash then

    if not yml.has_key?("hosts") or yml["hosts"] == nil
      sane["hosts"] = (yml.has_key?("host") and yml["host"] != nil) ? [].push(yml["host"]).uniq : [].push(yml["name"])
    end

    sane["domains"] = yml.has_key?("domain") ? yml.fetch("domains",[]).push(yml["domain"]).uniq : yml.fetch("domains",[])
    sane = yml.select { |key,val| compare_keys.include?(key) }
    sane = sane.each { |key,val| sane[key] = val.sort if val.kind_of?(Array) }.sort.to_h
  end
  return sane
end

app1 = sanitize(YAML::load(File.open(app1path))["applications"][0], compare_keys)
app2 = sanitize(YAML::load(File.open(app2path))["applications"][0], compare_keys)

exit app1 == app2
