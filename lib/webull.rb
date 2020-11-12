##
# This module provides an interface to Webull's API
module Targit
  class << self
    ##
    # Insert a helper .new() method for creating a new Account

    def new(*args)
      self::Account.new(*args)
    end

    def generate_tokens
      self::Authenticator.new.generate_tokens
    end
  end
end

require 'webull/version'
require 'webull/account'
require 'webull/authenticator'
