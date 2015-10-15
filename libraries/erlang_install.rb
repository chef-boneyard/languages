#
# Cookbook Name:: languages
# HWRP:: erlang_install
#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Resource::ErlangInstall < Resource::LWRPBase
    resource_name :erlang_install

    actions :install
    default_action :install

    attribute :version,  kind_of: String, name_attribute: true
    attribute :prefix,   kind_of: String, default: '/usr/local'
  end
end

class Chef
  class Provider::ErlangInstall < Provider::LWRPBase
    require_relative '_helper'
    include Languages::Helper

    provides :erlang_install

    def whyrun_supported?
      true
    end

    action(:install) do
      converge_by("Create #{new_resource}") do
        install_dependencies
        install_kerl
        activate_kerl
        build_erlang
        install_erlang
      end
    end

    protected

    def install_dependencies
      # from http://docs.basho.com/riak/latest/ops/building/installing/erlang/
      deps = %w(curl build-essential autoconf libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev git) if debian?
      deps = %w(gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel git) if rhel?

      deps.each do |dep|
        install_package(dep)
      end

      dir = Chef::Resource::Directory.new('erlang', run_context)
      dir.run_action(:create)
    end

    def install_package(package_name)
      package = Chef::Resource::Package.new(package_name, run_context)
      package.package_name(package_name)
      package.run_action(:install)
    end

    def install_kerl
      kerlfile = Chef::Resource::RemoteFile.new('kerl', run_context)
      kerlfile.source('https://raw.githubusercontent.com/spawngrid/kerl/master/kerl')
      kerlfile.path("#{Config[:file_cache_path]}/kerl")
      kerlfile.mode('0755')
      kerlfile.run_action(:create)
    end

    def activate_kerl
      activate_cmd = Chef::Resource::Execute.new('update_releases', run_context)
      activate_cmd.command("#{Config[:file_cache_path]}/kerl update releases")
      activate_cmd.run_action(:run)
    end

    def build_erlang
      kerl_cmd = Chef::Resource::Execute.new("build_kerl_#{new_resource.version}", run_context)
      # kerl_cmd.command("#{Config[:file_cache_path]}/kerl build #{new_resource.version} /usr/local/#{new_resource.version}")
      kerl_cmd.command("#{Config[:file_cache_path]}/kerl build #{new_resource.version} #{new_resource.version}")
      kerl_cmd.run_action(:run)
    end

    def install_erlang
      install_cmd = Chef::Resource::Execute.new("install_kerl_#{new_resource.version}", run_context)
      # install_cmd.command("#{Config[:file_cache_path]}/kerl install /usr/local/#{new_resource.version} #{new_resource.prefix}/erlang/#{new_resource.version}")
      install_cmd.command("#{Config[:file_cache_path]}/kerl install #{new_resource.version} #{new_resource.prefix}/erlang/#{new_resource.version}")
      install_cmd.run_action(:run)
    end
  end
end
