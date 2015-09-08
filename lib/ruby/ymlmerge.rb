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

# returns merged YAML to stdout
# usage ymlmerge.rb file1.yml file2.yml ... fileX.yml

require 'yaml'

class Hash
  def rmerge(h)
    self.merge!(h) {
      |key,_old,_new|
        if _old.class == Hash then
          _old.rmerge(_new)
        elsif _old.class == Array && _new.class == Array then
          if _old.first.is_a?(Hash) then
            _old.map { |_oel| _oel.rmerge(_new.find(-> {return {}}) { |_nel| _nel["name"]==_oel["name"] } ) }
          else
            _old
          end
        else
          _old
        end
    }
  end
end

def ymlsmerge(ymlarr)
  return ymlarr.count > 1 ? ymlsmerge(ymlarr.unshift(ymlarr.shift.rmerge(ymlarr.shift))) : YAML.dump(ymlarr.pop)
end

puts ymlsmerge(ARGV.map { |ymlfile| YAML.load(File.open(ymlfile)) })
