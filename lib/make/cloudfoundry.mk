# Cloud Foundry related setup
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

applcl_mfst = applcl_mfst.yml
apprmt_mfst = apprmt_mfst.yml

svilcl_mfst = svilcl_mfst.yml
svirmt_mfst = svirmt_mfst.yml

svclcl_mfst = svclcl_mfst.yml

sbklcl_mfst = sbklcl_mfst.yml
sbkrmt_mfst = sbkrmt_mfst.yml

upslcl_mfst = upslcl_mfst.yml
upsrmt_mfst = upsrmt_mfst.yml

yml_appseq = applications
yml_upsseq = user_provided_service_instances
yml_sbkseq = service_brokers
yml_sviseq = service_instances
yml_svcseq = services
yml_appdmn = apps_domain

artifact_mfst = manifest.yml
cfbindir = cfdir
appstack_file = stack.yml

.PRECIOUS: $(appdir)/%/$(artifact_mfst) $(appdir)/%/$(applcl_mfst) $(svidir)/%/$(svilcl_mfst) $(sbkdir)/%/$(sbklcl_mfst) $(svcdir)/%/$(svclcl_mfst) $(upsdir)/%/$(upslcl_mfst)

.INTERMEDIATE: $(appdir)/%/.appchanged $(svidir)/%/.svichanged $(upsdir)/%/.upschanged $(sbkdir)/%/.sbkchanged 

LOCALFILES += $(cfbindir) $(appstack_file)
CFOBJFILES = $(appdir)/*/.app $(svidir)/*/.svi $(upsdir)/*/.ups $(svcdir)/*/.svc $(sbkdir)/*/.sbk

cfarchive = $(cfbindir)/cfbin-$(cfbinrel)-$(cfbinver).tar.gz
cfbinary = $(cfbindir)/cf-$(cfbinrel)-$(cfbinver)
cfcmd = $(cfbindir)/cf

ifeq (,$(proxy))
  cfcall = $(cfcmd)
  curl = $(curlcmd)
else
  cfcall = env HTTP_PROXY=$(proxy) $(cfcmd)
  curl = $(curlcmd) -x $(proxy) --noproxy $(noproxy)
endif
ifeq ($(cfbinver),latest)
  cfarcurl = "$(cfbinurl)?release=$(cfbinrel)"
else
  cfarcurl = "$(cfbinurl)?release=$(cfbinrel)&version=$(cfbinver)"
endif

appstack_mfst := $(shell [ -s $(appstack_file) ] || lib/ruby/ymlmerge.rb $(stack_mflist) >$(appstack_file); echo $(appstack_file))

APPS := $(shell $(call r_ymllistdo,$(yml_appseq),|app| print app["name"]+" ") <$(appstack_mfst))
DPLAPPS := $(foreach app,$(APPS),$(appdir)/$(app)/.app)
DELAPPS := $(foreach app,$(APPS),$(appdir)/$(app)/.appdel)
REBINDAPPS := $(foreach app,$(APPS),$(appdir)/$(app)/.rebindapp)
ARTFCTS := $(foreach app,$(APPS),$(srcdir)/$(app).zip)
SVIS := $(shell $(call r_ymllistdo,$(yml_sviseq),|svi| print svi["name"]+" ") <$(appstack_mfst))
DPLSVIS := $(foreach svi,$(SVIS),$(svidir)/$(svi)/.svi)
DELSVIS := $(foreach svi,$(SVIS),$(svidir)/$(svi)/.svidel)
UPSI := $(shell $(call r_ymllistdo,$(yml_upsseq),|ups| print ups["name"]+" ") <$(appstack_mfst))
DPLUPSI := $(foreach ups,$(UPSI),$(upsdir)/$(ups)/.ups)
DELUPSI := $(foreach ups,$(UPSI),$(upsdir)/$(ups)/.upsdel)
SVCS := $(sort $(shell $(call r_ymllistdo,$(yml_sviseq),|svc| print svc["service_plan"]["service"]["label"]+" ") <$(appstack_mfst)))
DPLSVCS := $(foreach svc,$(SVCS),$(svcdir)/$(svc)/.svc)
DELSVCS := $(foreach svc,$(SVCS),$(svcdir)/$(svc)/.svcdel)
SBKS := $(shell $(call r_ymllistdo,$(yml_sbkseq),|sbk| print sbk["name"]+" ") <$(appstack_mfst))
DPLSBKS := $(foreach sbk,$(SBKS),$(sbkdir)/$(sbk)/.sbk)
DELSBKS := $(foreach sbk,$(SBKS),$(sbkdir)/$(sbk)/.sbkdel)

ifeq ($(filter $(MAKECMDGOALS),$(MAKEFILE_TARGETS_WITHOUT_INCLUDE)),)
  -include $(DPLAPPS:$(appdir)/%/.app=$(appdir)/%/.appdeps)
  -include $(DPLSVIS:$(svidir)/%/.svi=$(svidir)/%/.svideps)
  -include $(DPLUPSI:$(upsdir)/%/.ups=$(upsdir)/%/.upsdeps)
  -include $(DPLSVCS:$(svcdir)/%/.svc=$(svcdir)/%/.svcdeps)
  -include $(DPLSBKS:$(sbkdir)/%/.sbk=$(sbkdir)/%/.sbkdeps)
endif

purge_applications: $(DELAPPS)

purge_services: $(DELSVCS)

purge_upsis: $(DELUPSI)

purge_brokers: $(DELSBKS)

deploy_applications: $(DPLAPPS)

rebind_applications: $(REBINDAPPS)

deploy_service_instances: $(DPLSVIS)

deploy_user_provided_service_instances: $(DPLUPSI)

deploy_services: $(DPLSVCS)

deploy_service_brokers: $(DPLSBKS)

$(cfspace)_artifacts.tar.gz: $(ARTFCTS)
	$(shmute)tar -czf $@ $^

$(cfarchive): | $(cfbindir)/.dir
	$(info $(call i_cfdwnld))
	$(shmute)$(curl) -o $@ $(cfarcurl) $(nulout)

$(cfbinary): $(cfarchive)
	$(info $(call i_cfunzip))
	$(shmute)tar -C $(cfbindir) -xzmf $<
	$(shmute)mv $(cfbindir)/cf $@

$(cfcmd): $(cfbinary)
	$(shmute)ln -fs $(<F) $@

cfauth: $(cfcmd)
	$(shmute)lib/sh/cfset "$(cfcall)" "$(strip $(cfapi))" "$(strip $(cfuser))" "$(strip $(cfpass))" "$(strip $(cforg))" "$(strip $(cfspace))"$(nulout)

cfset: $(cfcmd) cfauth
	$(eval space_guid:=$(shell $(cfcall) space --guid $(cfspace)))
	$(shmute)echo $(call i_cflogin,User:$(cfuser) API:$(cfapi) Org:$(cforg) Space:$(cfspace) Space GUID:$(space_guid))

$(appstack_mfst): $(stack_mflist)
	$(shmute)lib/ruby/ymlmerge.rb $^ >$@

$(appdir)/%/.app:
	$(eval app_name:=$(subst $(appdir)/,,$(@D)))
	$(eval app_path:=$(shell $(call r_ymllistelemval,$(yml_appseq),|app| app["name"]=="$(app_name)",["path"]) <$(@D)/$(applcl_mfst)))
	$(eval app_dead:=$(shell $(cfcall) app $(app_name) | grep -q "\ running\ "; echo $$?))
	$(eval app_services:=$(shell $(call r_ymllistelemval,$(yml_appseq),|app| app["name"]=="$(app_name)",["services"]) <$(@D)/$(apprmt_mfst)))
	$(shmute)if [ -f $| ]; then for bsvc in $(app_services); do \
          echo "unbinding application: $(app_name) (service: $${bsvc})"; \
          $(cfcall) unbind-service $(app_name) $${bsvc} $(nulout); \
        done; fi
	$(eval push_arg:=$(shell $(call r_appgetattr,$(app_name),.fetch("env",{}).fetch("push_argument","")) <$(@D)/$(applcl_mfst)))
	$(shmute)if [ -f $| -o "$(app_dead)" != "0" ]; then echo "$(call i_apppush,$(app_name))"; fi
	$(shmute)if [ -f $| -o "$(app_dead)" != "0" ]; then $(cfcall) push -p $(@D)/$(app_path) -f $(@D)/$(applcl_mfst) $(push_arg) $(nulout); fi
	$(eval domain:=$(shell $(call r_ymlelemval,$(yml_appdmn)) <$(appstack_file)))
	$(eval app_name:=$(subst $(appdir)/,,$(@D)))
	$(eval desc:=$(shell $(call r_appgetattr,$(app_name),.fetch("env",{}).fetch("description","")) <$(@D)/$(applcl_mfst)))
	$(eval disp_name:=$(shell $(call r_appgetattr,$(app_name),.fetch("env",{}).fetch("display_name","")) <$(@D)/$(applcl_mfst)))
	$(eval image_url:=$(shell $(call r_appgetattr,$(app_name),.fetch("env",{}).fetch("image_url","")) <$(@D)/$(applcl_mfst)))
	$(eval register_in:=$(shell $(call r_appgetattr,$(app_name),.fetch("env",{}).fetch("register_in","")) <$(@D)/$(applcl_mfst)))
	$(eval auth_username:=$(shell $(call r_appgetattr,$(register_in),.fetch("env",{}).fetch("AUTH_USER","")) <$(appdir)/$(register_in)/$(applcl_mfst)))
	$(eval auth_password:=$(shell $(call r_appgetattr,$(register_in),.fetch("env",{}).fetch("AUTH_PASS","")) <$(appdir)/$(register_in)/$(applcl_mfst)))
	$(shmute)if [ ! -z "$(register_in)" ]; then $(appdir)/$(register_in)/register.sh -b "http://$(register_in).$(domain)" -u "$(auth_username)" -p "$(auth_password)" -a "$(app_name)" -n "$(app_name)" -s "$(disp_name)" -d "$(desc)" -i "$(image_url)"; fi
	$(shmute)rm -f $|
	$(shmute)touch $@

$(appdir)/%/.appdel: $(appdir)/%/.dir | cfset
	$(eval app_name:=$(subst $(appdir)/,,$(@D)))
	$(eval app_missing:=$(shell $(cfcall) app $(app_name) $(devnull); echo $$?))
	$(shmute)if [ "$(app_missing)" == "0" ]; then echo "$(call i_appdele,$(app_name))"; fi
	$(shmute)if [ "$(app_missing)" == "0" ]; then $(cfcall) delete -f $(app_name) $(nulout); fi

$(appdir)/%/.rebindapp:
	$(eval app_name:=$(subst $(appdir)/,,$(@D)))
	$(eval app_services:=$(shell $(call r_ymllistelemval,$(yml_appseq),|app| app["name"]=="$(app_name)",["services"]) <$(@D)/$(applcl_mfst)))
	$(shmute)if [ -f $| ]; then for bsvc in $(app_services); do \
          echo "rebind application: $(app_name) (service: $${bsvc})"; \
          $(cfcall) unbind-service $(app_name) $${bsvc} $(nulout); \
          $(cfcall) bind-service $(app_name) $${bsvc} $(nulout); \
        done; fi
	@echo "$(call i_apprstg) $(app_name)";
	$(cfcall) restage $(app_name) $(nulout);
	$(shmute)rm -f $|
	$(shmute)touch $@

$(svidir)/%/.svi:
	$(eval svi_name:=$(subst $(svidir)/,,$(@D)))
	$(eval svi_missing:=$(shell $(cfcall) service $(svi_name) $(devnull); echo $$?))
	$(eval svi_service:=$(shell $(call r_ymllistelemval,$(yml_sviseq),|svi| svi["name"]=="$(svi_name)",["service_plan"]["service"]["label"]) <$(@D)/$(svilcl_mfst)))
	$(eval svi_plan:=$(shell $(call r_ymllistelemval,$(yml_sviseq),|svi| svi["name"]=="$(svi_name)",["service_plan"]["name"]) <$(@D)/$(svilcl_mfst)))
	$(shmute)if [ "$(svi_missing)" == "1" ]; then $(cfcall) cs $(svi_service) $(svi_plan) $(svi_name) $(nulout); fi
	$(shmute)if [ -f $| -a "$(svi_missing)" == "0" ]; then $(cfcall) update-service $(svi_name) -p $(svi_plan) $(nulout); fi
	$(shmute)rm -f $|
	$(shmute)touch $@

$(svidir)/%/.svidel: $(svidir)/%/.dir | cfset
	$(eval svi_name:=$(subst $(svidir)/,,$(@D)))
	$(eval svi_missing:=$(shell $(cfcall) service $(svi_name) $(devnull); echo $$?))
	$(shmute)if [ "$(svi_missing)" == "0" ]; then echo "$(call i_svidele,$(svi_name))"; fi
	$(shmute)if [ "$(svi_missing)" == "0" ]; then $(cfcall) ds $(svi_name) -f $(nulout); fi

$(upsdir)/%/.ups:
	$(eval upsi_name:=$(subst $(upsdir)/,,$(@D)))
	$(eval upsi_missing:=$(shell $(cfcall) service $(upsi_name) $(devnull); echo $$?))
	$(eval upsi_creds:=$(shell $(call r_ymllistelemvaljson,$(yml_upsseq),|ups| ups["name"]=="$(upsi_name)",["credentials"]) <$(@D)/$(upslcl_mfst)))
	$(eval upsi_boundapps:=$(shell $(call r_ymllistdo,$(yml_appseq),|app| if app["services"]; if app["services"].include?("$(upsi_name)"); print app["name"]+" " end end ) <$(appstack_mfst)))
	$(shmute)if [ "$(upsi_missing)" != "0" ]; then echo "$(call i_upscrte,$(upsi_name))"; fi
	$(shmute)if [ "$(upsi_missing)" != "0" ]; then $(cfcall) cups $(upsi_name) -p '$(upsi_creds)' $(nulout); fi
	$(shmute)if [ -f $| -a "$(upsi_missing)" == "0" ]; then echo "$(call i_upsupdt,$(upsi_name))"; fi
	$(shmute)if [ -f $| -a "$(upsi_missing)" == "0" ]; then $(cfcall) uups $(upsi_name) -p '$(upsi_creds)' $(nulout); fi
	$(shmute)if [ -f $| -a "$(upsi_missing)" == "0" ]; then for bapp in $(upsi_boundapps); do if [ "`$(cfcall) app $${bapp} >/dev/null;echo $$?`" == "0" ]; then \
          echo "$(call i_apprstg) $${bapp}"; \
          $(cfcall) unbind-service $${bapp} $(upsi_name) $(nulout); \
          $(cfcall) bind-service $${bapp} $(upsi_name) $(nulout); \
          $(cfcall) restage $${bapp} $(nulout); \
        fi done; fi
	$(shmute)rm -f $|
	$(shmute)touch $@

$(upsdir)/%/.upsdel: $(upsdir)/%/.dir | cfset
	$(eval ups_name:=$(subst $(upsdir)/,,$(@D)))
	$(eval ups_missing:=$(shell $(cfcall) service $(ups_name) $(devnull); echo $$?))
	$(shmute)if [ "$(ups_missing)" == "0" ]; then echo "$(call i_upsdele,$(ups_name))"; fi
	$(shmute)if [ "$(ups_missing)" == "0" ]; then $(cfcall) ds $(ups_name) -f $(nulout); fi

$(svcdir)/%/.svc:
	$(eval svc_name:=$(subst $(svcdir)/,,$(@D)))
	$(shmute)$(cfcall) enable-service-access $(svc_name) $(nulout)
	$(shmute)touch $@

$(svcdir)/%/.svcdel: $(svcdir)/%/.dir | cfset
	$(eval svc_name:=$(subst $(svcdir)/,,$(@D)))
	$(shmute)echo "$(call i_svcdele,$(svc_name))"
	$(shmute)$(cfcall) purge-service-offering $(svc_name) -f $(nulout)

$(sbkdir)/%/.sbk:
	$(eval sbk_name:=$(subst $(sbkdir)/,,$(@D)))
	$(eval sbk_missing:=$(shell $(cfcall) service-brokers | grep -q "^$(sbk_name)\ "; echo $$?))
	$(eval auth_username:=$(shell $(call r_ymllistelemval,$(yml_sbkseq),|sbk| sbk["name"]=="$(sbk_name)",["auth_username"]) <$(@D)/$(sbklcl_mfst)))
	$(eval auth_password:=$(shell $(call r_ymllistelemval,$(yml_sbkseq),|sbk| sbk["name"]=="$(sbk_name)",["auth_password"]) <$(@D)/$(sbklcl_mfst)))
	$(eval broker_url:=$(shell $(call r_ymllistelemval,$(yml_sbkseq),|sbk| sbk["name"]=="$(sbk_name)",["broker_url"]) <$(@D)/$(sbklcl_mfst)))
	$(shmute)if [ "$(sbk_missing)" != "0" ]; then echo "$(call i_sbkcrte,$(sbk_name))"; fi
	$(shmute)if [ "$(sbk_missing)" != "0" ]; then $(cfcall) create-service-broker $(sbk_name) $(auth_username) $(auth_password) $(broker_url) $(nulout); fi
	$(shmute)if [ -f $| -a "$(sbk_missing)" == "0" ]; then echo "$(call i_sbkupdt,$(sbk_name))"; fi
	$(shmute)if [ -f $| -a "$(sbk_missing)" == "0" ]; then $(cfcall) update-service-broker $(sbk_name) $(auth_username) $(auth_password) $(broker_url) $(nulout); fi
	$(shmute)rm -f $|
	$(shmute)touch $@

$(sbkdir)/%/.sbkdel: $(sbkdir)/%/.dir | cfset
	$(eval sbk_name:=$(subst $(sbkdir)/,,$(@D)))
	$(shmute)echo "$(call i_sbkdele,$(sbk_name))"
	$(shmute)$(cfcall) delete-service-broker $(sbk_name) -f $(nulout)

$(appdir)/%/.appdeps: $(appdir)/%/$(applcl_mfst)
	$(eval appdeps:=$(shell lib/ruby/appdeps.rb $< $(appstack_mfst) $(svidir) $(upsdir) $(appdir)))
	$(shmute)echo "$(@D)/.app $@: $(appdeps) $^ | $(@D)/.appchanged" >$@

$(svidir)/%/.svideps: $(svidir)/%/$(svilcl_mfst)
	$(eval svideps:=$(svcdir)/$(shell $(call r_svigetdep,$(subst $(svidir)/,,$(@D))) <$<)/.svc)
	$(shmute)echo "$(@D)/.svi $@: $(svideps) $^ | $(@D)/.svichanged" >$@

$(svcdir)/%/.svcdeps: $(svcdir)/%/$(svclcl_mfst)
	$(eval svcdeps:=$(sbkdir)/$(shell $(call r_ymllistelemval,$(yml_svcseq),|svc| svc,["broker"]) <$<)/.sbk)
	$(shmute)echo "$(@D)/.svc $@: $(svcdeps) $^" >$@

$(upsdir)/%/.upsdeps: $(appstack_mfst) $(upsdir)/%/$(upslcl_mfst)
	$(eval upsdeps:=$(shell lib/ruby/envdeps.rb upsi_names $(subst $(upsdir)/,,$(@D)) $< $(appdir)))
	$(shmute)echo "$(@D)/.ups $@: $(upsdeps) $^ | $(@D)/.upschanged" >$@

$(sbkdir)/%/.sbkdeps: $(appstack_mfst) $(sbkdir)/%/$(sbklcl_mfst)
	$(eval sbkdeps:=$(shell lib/ruby/envdeps.rb service_broker_names $(subst $(sbkdir)/,,$(@D)) $< $(appdir)))
	$(shmute)echo "$(@D)/.sbk $@: $(sbkdeps) $^ | $(@D)/.sbkchanged" >$@

$(appdir)/%/.appchanged: $(appdir)/%/$(applcl_mfst) $(appdir)/%/$(apprmt_mfst)
	$(shmute)-lib/ruby/appmftcompare.rb $^ || touch $@

$(svidir)/%/.svichanged: $(svidir)/%/$(svirmt_mfst) $(svidir)/%/$(svilcl_mfst)
	$(shmute)-$(call r_ymlcmpr,$(word 1,$^),$(word 2,$^)) || touch $@

$(upsdir)/%/.upschanged: $(upsdir)/%/$(upsrmt_mfst) $(upsdir)/%/$(upslcl_mfst)
	$(shmute)-$(call r_ymlcmpr,$(word 1,$^),$(word 2,$^)) || touch $@

$(sbkdir)/%/.sbkchanged: $(sbkdir)/%/$(sbkrmt_mfst) $(sbkdir)/%/$(sbklcl_mfst)
	$(shmute)-$(call r_ymlcmpr,$(word 1,$^),$(word 2,$^)) || touch $@

$(cfspace)_summary.json : | cfset
	$(shmute)$(cfcall) curl /v2/spaces/$(space_guid)/summary >$@

$(cfspace)_sbrokers.json: | cfset
	$(shmute)$(cfcall) curl /v2/service_brokers >$@

$(cfspace)_services.json: | cfset
	$(shmute)$(cfcall) curl /v2/services >$@

$(cfspace)_upsi.json: | cfset
	$(shmute)$(cfcall) curl /v2/user_provided_service_instances >$@

$(cfspace)_sbrokers.yml: $(cfspace)_sbrokers.json
	$(shmute)lib/ruby/cfsb2mft.rb <$< >$@

$(cfspace)_upsi.yml: $(cfspace)_upsi.json
	$(shmute)lib/ruby/cfupsi2mft.rb $(space_guid) <$< >$@

$(cfspace)_summary.yml: $(cfspace)_summary.json $(cfspace)_services.json $(cfspace)_sbrokers.json
	$(shmute)lib/ruby/cfspace2mft.rb $^ >$@

$(sbkdir)/%/$(sbkrmt_mfst): $(cfspace)_sbrokers.yml $(sbkdir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_sbkseq),name,$(subst $(sbkdir)/,,$(@D))) <$< >$@

$(sbkdir)/%/$(sbklcl_mfst): $(appstack_mfst) $(sbkdir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_sbkseq),name,$(subst $(sbkdir)/,,$(@D))) <$(appstack_mfst) >$@

$(upsdir)/%/$(upsrmt_mfst): $(cfspace)_upsi.yml $(upsdir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_upsseq),name,$(subst $(upsdir)/,,$(@D))) <$< >$@

$(upsdir)/%/$(upslcl_mfst): $(appstack_mfst) $(upsdir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_upsseq),name,$(subst $(upsdir)/,,$(@D))) <$(appstack_mfst) >$@

$(svcdir)/%/$(svclcl_mfst): $(appstack_mfst) $(svcdir)/%/.dir
	$(eval service_broker:=$(shell $(call r_svcgetdep,$(subst $(svcdir)/,,$(@D))) <$<))
	$(shmute)$(ruby) 'puts YAML.dump({"$(yml_svcseq)" => [{"label" => "$(subst $(svcdir)/,,$(@D))", "broker" => "$(service_broker)"}]})' >$@

$(svidir)/%/$(svirmt_mfst): $(cfspace)_summary.yml $(svidir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_sviseq),name,$(subst $(svidir)/,,$(@D))) <$< >$@

$(svidir)/%/$(svilcl_mfst): $(appstack_mfst) $(svidir)/%/.dir
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_sviseq),name,$(subst $(svidir)/,,$(@D))) <$(appstack_mfst) >$@

$(appdir)/%/$(apprmt_mfst): $(cfspace)_summary.yml $(appdir)/%/.dir
	$(eval domain:=$(shell $(call r_ymlelemval,$(yml_appdmn)) <$(appstack_file)))
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_appseq),name,$(subst $(appdir)/,,$(@D))) <$< >$@
	$(shmute)-lib/ruby/appmftunify.rb $@ $(domain) >$@.tmpl; mv $@.tmpl $@

$(appdir)/%/$(applcl_mfst): $(appdir)/%/$(artifact_mfst) $(appstack_mfst)
	$(info $(call i_appcrmf,$(subst $(appdir)/,,$(@D))))
	$(shmute)$(call r_ymlGetLstElemByNamedVal,$(yml_appseq),name,$(subst $(appdir)/,,$(@D))) <$(appstack_mfst) >$@
	$(shmute)lib/ruby/ymlmerge.rb $@ $< >$@.tmp1; mv $@.tmp1 $@
	$(eval domain:=$(shell $(call r_ymlelemval,$(yml_appdmn)) <$(appstack_file)))
	$(shmute)-lib/ruby/appmftunify.rb $@ $(domain) >$@.tmpl; mv $@.tmpl $@

$(appdir)/%/$(artifact_mfst): $(srcdir)/%.zip $(appdir)/%/.dir
	$(info $(call i_appunzp,$(subst $(appdir)/,,$(@D))))
	$(shmute)$(ruby) 'puts YAML.dump({"$(yml_appseq)" => ""})' >$@
	$(shmute)$(unzip) -d $(@D) $<

$(srcdir)/%.zip: $(srcdir)/.dir
	$(eval appnamereal:=$(basename $(@F)))
	$(info $(call i_appdnld,$(appnamereal)))
	$(eval mftsrcurl:=$(shell $(call r_appgetattr,$(appnamereal),["env"]["artifact_srcurl"]) <$(appstack_mfst)))
	$(eval mftafname:=$(shell $(call r_appgetattr,$(appnamereal),["env"]["artifact_name"]) <$(appstack_mfst)))
	$(eval mftappver:=$(shell $(call r_appgetattr,$(appnamereal),["env"]["VERSION"]) <$(appstack_mfst)))
	$(eval appname:=$(if $(mftafname),$(mftafname),$(appnamereal)))
	$(eval appver:=$(if $(mftappver),$(mftappver),$(artifact_ver)))
	$(eval srcurl:=$(if $(mftsrcurl),$(mftsrcurl),$(afcturl)))
	$(shmute)$(curl) -o $@ $(srcurl) $(nulout); if [ "`echo $$?`" != "0" ]; then echo "$(call i_appdler,$(appnamereal))"; fi

