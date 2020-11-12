require 'userinput'

module Webull
  ##
  # Authenticator generates access/refresh tokens from a username/password
  class Authenticatcor
    def generate_tokens
    end

    private

    def username
      @username ||= UserInput.new(
        message: 'Webull username: ',
        validation: /^\w+$/
      )
    end

    def password
      @password ||= UserInput.new(
        message: 'Webull password: ',
        secret: true
        validation: /.*/
      )
    end
  end
end
