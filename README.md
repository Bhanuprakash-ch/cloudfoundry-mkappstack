# cloudfoundry-mkappstack
simple automation to create a CF multi application stack

Description
===========

the main purpose is to store live CF spaces and redeploy
these later on, also to create a recipe for a whole CF
application stack to be automatically deployed into a
CF space some time later

it is possible to manipulate CF entitles, namely:
* applications
* service brokers
* services
* service instances
* user-provided service instances

the YAML setup is based on CF application manifests in 
most parts (applications list), whereas other lists are
proprietary for the automation

there are 6 important application keys, that need
to be considered while constructing the CF application stack:

* name - used to name the CF application, also used to construct artifact URL if necessary
* env::VERSION - used to decide whether to upgrade CF application with an artifact, also used to construct artifact URL if necessary
* env::artifact_name - (optional) used to construct artifact URL if an application name is not matching artifact name
* env::artifact_srcurl - (optional) used for artifacts that don't match general artifact URL scheme
* env::upsi_names - (optional) indicates the application is providing an user-provided service instance of given name
* env::service_broker_names - (optional) indicates the application is providing a service broker of given name

Usage
=====
the main program is a GNU Makefile, that uses certain
configuration files to execute targets - all described
below. configuration variables can be overriden using
command line make call, i.e.
```
make somevar=somevalue othervar=othervalue target
```

the artifacts need to be zip files:
* containing app manifest.yml (if absent, all required data needs to be a part of full stack manifest)
* containing all other app files, i.e.:
```
target/artifact-0.0.1.jar
manifest.yml
```
* files in zip archive should not be enclosed by any top directory structure

configuration files:
* secret.mk should contain CF setup, including confidential data
* appstack.mk contains all settings, including manifest file names
* manifest files (YAML format, as in *.yml.tmpl)

available make targets:
* cfset - download and set up CF CLI binary, authenticate and target CF space
* discover - retrieve targeted space information and create matching manifest file
* artifact-pack - retrieve all artifacts mentioned in manifest, put all into a tar.gz package
* deploy - install appstack in the CF org/space, according to the main manifest
* clean - wipe all local artifacts
* cfclean - wipe most of CF self-created objects (according to manifests)
* wipeall - cfclean + clean

License
=======
Copyright (c) 2015 Intel Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

