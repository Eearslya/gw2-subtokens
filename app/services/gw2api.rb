# frozen_string_literal: true

# Service class to interface with the Guild Wars 2 API.
# https://api.guildwars2.com/v2/
class Gw2api
  def self.createsubtoken(token_params)
    Gw2api.instance.call('createsubtoken', token_params)
  end

  def self.tokeninfo(token)
    Gw2api.instance.call('tokeninfo', access_token: token)
  end

  def self.instance
    @@instance ||= Gw2api.new
  end

  def call(endpoint, params)
    Rails.logger.info("API Call to #{endpoint}")
    Rails.logger.info("Params: #{params}")
    response = api[endpoint].get(params: params)
    Rails.logger.info("Response: #{response}")
    JSON.parse!(response.body)
  end

  private

  def api
    @api ||= RestClient::Resource.new base_url
  end

  def base_url
    'https://api.guildwars2.com/v2/'
  end
end
