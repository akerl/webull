require 'httparty'

module Webull
  ##
  # Account defines a user account object for the Webull API
  class Account
    def initialize(params = {})
      @tokens = params[:tokens] || raise('API tokens not provided')
      @udid = params[:udid] || raise('Device ID (udid) not provided')
    end

    def refresh
      resp = HTTParty.post(
        'https://userapi.webull.com/api/passport/refreshToken',
        query: { refreshToken: @tokens.refresh },
        headers: headers
      )
      raise("Refresh request failed: #{resp.code}") unless resp.success?
      @tokens = Tokens.from_resp(resp)
    end

    def account_id
      return @account_id if @account_id
      resp = HTTParty.get(
        'https://tradeapi.webullbroker.com/api/trade/account/getSecAccountList/v4',
        headers: headers
      )
      raise("Account ID request failed: #{resp.code}") unless resp.success?
      raise("Account ID error received: #{resp['msg']}") unless resp['success']
      @account_id = resp['data'].first['secAccountId']
    end

    def orders(params = {})
      HTTParty.get(
        'https://tradeapi.webullbroker.com/api/trade/v2/option/list',
        query: {
          secAccountId: account_id,
          status: 'Filled'
        }.merge(params),
        headers: headers
      )
    end

    private

    def headers
      {
        'did' => @udid,
        'access_token' => @tokens.access,
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip, deflate',
        'Content-Type' => 'application/json'
      }
    end
  end
end
