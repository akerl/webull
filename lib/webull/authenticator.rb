require 'userinput'
require 'httparty'
require 'digest'

module Webull
  ##
  # Tokens object describes a full set of API tokens
  class Tokens
    attr_reader :access, :refresh

    def initialize(params = {})
      @access = params[:access]
      @refresh = params[:refresh]
    end

    def self.from_resp(resp)
      Tokens.new(
        access: resp['accessToken'],
        refresh: resp['refreshToken']
      )
    end
  end

  ##
  # Authenticator generates access/refresh tokens from a username/password
  class Authenticator
    attr_reader :udid

    def initialize(udid)
      @udid = udid
    end

    def generate_tokens # rubocop:disable Metrics/MethodLength
      params = {
        account: username,
        accountType: 2,
        deviceId: udid,
        regionId: 6,
        grade: 1,
        pwd: hashed_password,
        verificationCode: mfa
      }
      resp = HTTParty.post(
        'https://userapi.webull.com/api/passport/login/v3/account',
        body: params.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      raise("Login request failed: #{resp.code}") unless resp.success?
      Tokens.from_resp(resp)
    end

    private

    def mfa
      return @mfa if @mfa
      generate_mfa!
      @mfa = UserInput.new(
        message: 'Webull MFA code',
        validation: /^\d{6}$/
      ).ask
    end

    def generate_mfa!
      HTTParty.get(
        'https://userapi.webull.com/api/passport/verificationCode/sendCode',
        query: {
          account: username,
          accountType: 2,
          deviceId: udid,
          codeType: 5,
          regionCode: 1
        }
      )
    end

    def username
      @username ||= UserInput.new(
        message: 'Webull username',
        validation: /^.*@.*$/
      ).ask
    end

    def password
      @password ||= UserInput.new(
        message: 'Webull password',
        secret: true,
        validation: /.*/
      ).ask
    end

    def hashed_password
      @hashed_password ||= Digest::MD5.hexdigest('wl_app-a&b@!423^' + password)
    end
  end
end
