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

# fills manifest with default values when not specified and unifies to the same format
# usage appmftunify.rb <app_mft_path> <default_domain_name>

require 'yaml'

manifest = ARGV.shift || "app.yml"
default_domain   = ARGV.shift

def unify(yml, domain)
  if yml == nil then
    return nil
  end
  yml["instances"]  ||= 1
  yml["disk_quota"] ||= "1024M"
  yml["memory"]     ||= "1024M"

  if yml.has_key?("domain") then
    yml["domains"] ||= []
    yml["domains"] = yml["domains"].push(yml["domain"]).uniq
    yml.delete("domain")
  end
  yml["domains"] ||= [domain]
  return yml.each { |key,val| yml[key] = val.sort if val.kind_of?(Array) }.sort.to_h
end

content = YAML::load(File.open(manifest))
content["applications"][0] = unify(content["applications"][0], default_domain)
puts YAML.dump(content)
