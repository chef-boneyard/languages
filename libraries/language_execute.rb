class Chef
  class Resource::LanguageExecute < Resource::LWRPBase
    actions :execute
    default_action :execute

    attribute :command, kind_of: String, name_attribute: true
    attribute :version, kind_of: String
    attribute :environment, kind_of: Hash, default: {}
    attribute :prefix, kind_of: String
  end
end
