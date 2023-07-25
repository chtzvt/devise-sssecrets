# frozen_string_literal: true

require "devise"
require "sssecrets"

# This module provides a devise extension to use Sssecrets instead
# of Devise's default friendly token generator.
#
# Please consult the link below to learn more about Structured Secrets and
# the sssecrets gem.
#
# @see https://github.com/chtzvt/sssecrets
module Devise
  mattr_accessor :friendly_token_types
  mattr_accessor :friendly_token_org

  # Configuration block to set multiple token prefixes with sssecrets types and org
  # The available sssecret token prefixes (org and types) can be set up in your Devise
  # configuration block:
  #
  #   Devise.setup do |config|
  #    config.friendly_token_org = 'dv' # Set your sssecret token organization. Defaults to "dv".
  #    config.friendly_token_types[:default] = 'ft' # Add your sssecret token types like so. Default is "ft".
  #    config.friendly_token_types[:user] = 'usr'
  #    config.friendly_token_types[:admin] = 'adm'
  #    # Any other Devise configuration...
  #   end
  def self.setup
    self.friendly_token_types = { default: "ft" }
    self.friendly_token_org = "dv"
    yield(self)
  end

  def self.sssecrets_type_for(type)
    friendly_token_types[type] || friendly_token_types[:default] || "ft"
  end

  # The overridden Devise#friendly_token implementation has been extended to accept two optional parameters:
  #
  #  prefix_type: Specifies the type of the token prefix. If not provided, it defaults to :default.
  #  org: Specifies the organization for the friendly token. If not provided, the default organization is used.
  #
  # Note: the original implementation's length parameter is now ignored.
  def self.friendly_token(**kwargs)
    type = kwargs[:type] || :default
    org = kwargs[:org] || friendly_token_org || "dv"

    generator = SimpleStructuredSecrets.new(org, sssecrets_type_for(type))
    generator.generate
  end
end

Devise.add_module(:sssecrets, insert_at: 0)
