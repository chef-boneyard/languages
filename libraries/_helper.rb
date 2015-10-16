#
# Cookbook Name:: opscode-ci
# Library:: _helper
#
# Author:: Seth Chisamore <schisamo@getchef.com>
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
  end
end

Chef::Recipe.send(:include, Languages::Helper)
Chef::Resource.send(:include, Languages::Helper)
