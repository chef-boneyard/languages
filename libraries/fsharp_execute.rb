require_relative 'language_execute'

class Chef
  class Resource::FsharpExecute < Resource::LanguageExecute
    resource_name :fsharp_execute
  end

  class Provider::FsharpExecute < Provider::LanguageExecute
    provides :fsharp_execute
  end

  #
  # @see Chef::Resource::LanguageExecute#environment
  #
  def environment
    environment = super
    # We run `ldconfig` when Rust is installed but we'll go ahead and
    # set `LD_LIBRARY_PATH` just to be safe.
    environment['LD_LIBRARY_PATH'] = ::File.join(new_resource.prefix, 'lib')
    environment['PKG_CONFIG_PATH'] = ::File.join(new_resource.prefix, 'lib/pkgconfig')
    environment
  end
end
