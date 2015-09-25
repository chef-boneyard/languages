if defined?(ChefSpec)
  ChefSpec.define_matcher :rust_install
  def run_rust_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rust_install, :install, resource_name)
  end
end
