#
# Cookbook Name:: opscode-ci
# Library:: _helper
#
# Author:: Tyler Cloke <tyler@chef.io>
#
# Copyright 2013-2014, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'json'

begin
  require 'chef/sugar'
rescue LoadError
  Chef::Log.warn 'chef-sugar gem could not be loaded.'
end

# Various code vendored from omnibus cookbook
module Languages
  module Helper
    include Chef::Sugar::DSL if Chef.const_defined?('Sugar')

    #
    # Performs a `File.join` but ensures all forward slashes are replaced
    # by backward slashes.
    #
    # @return [String]
    #
    def windows_safe_path_join(*args)
      ::File.join(args).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
    end

    #
    # Performs a `File.expand_path` but ensures all forward slashes are
    # replaced by backward slashes.
    #
    # @return [String]
    #
    def windows_safe_path_expand(arg)
      ::File.expand_path(arg).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
    end

    #
    # Performs a WMI query using WIN32OLE from the Ruby Stdlib
    #
    # @return [String]
    #
    def wmi_property_from_query(wmi_property, wmi_query)
      require 'win32ole'
      wmi = ::WIN32OLE.connect('winmgmts://')
      result = wmi.ExecQuery(wmi_query)
      return nil unless result.each.count > 0
      result.each.next.send(wmi_property)
    end

    # Execute the given command, removing any Ruby-specific environment
    # variables. This is an "enhanced" version of +Bundler.with_clean_env+,
    # which only removes Bundler-specific values. We need to remove all
    # values, specifically:
    #
    # - _ORIGINAL_GEM_PATH
    # - GEM_PATH
    # - GEM_HOME
    # - GEM_ROOT
    # - BUNDLE_BIN_PATH
    # - BUNDLE_GEMFILE
    # - RUBYLIB
    # - RUBYOPT
    # - RUBY_ENGINE
    # - RUBY_ROOT
    # - RUBY_VERSION
    #
    # The original environment restored at the end of this call.
    #
    # @param [Proc] block
    #   the block to execute with the cleaned environment
    #
    def with_clean_env(&block)
      original = ENV.to_hash

      ENV.delete('_ORIGINAL_GEM_PATH')
      ENV.delete_if { |k, _| k.start_with?('BUNDLE_') }
      ENV.delete_if { |k, _| k.start_with?('GEM_') }
      ENV.delete_if { |k, _| k.start_with?('RUBY') }

      block.call
    ensure
      ENV.replace(original.to_hash)
    end
  end
end

Chef::Recipe.send(:include, Languages::Helper)
Chef::Resource.send(:include, Languages::Helper)
