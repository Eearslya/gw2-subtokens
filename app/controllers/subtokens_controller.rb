# frozen_string_literal: true

# Main controller of the app, deals with the entire lifecycle of creating
# subtokens.
class SubtokensController < ApplicationController
  ALL_PERMISSIONS = %w[
    account
    builds
    characters
    guilds
    inventories
    progression
    pvp
    tradingpost
    unlocks
    wallet
  ].freeze

  KNOWN_ENDPOINTS = %w[
    /v2/account
    /v2/account/achievements
    /v2/account/bank
    /v2/account/dailycrafting
    /v2/account/dungeons
    /v2/account/dyes
    /v2/account/finishers
    /v2/account/gliders
    /v2/account/home/cats
    /v2/account/home/nodes
    /v2/account/inventory
    /v2/account/luck
    /v2/account/mailcarriers
    /v2/account/mapchests
    /v2/account/masteries
    /v2/account/mastery/points
    /v2/account/materials
    /v2/account/minis
    /v2/account/mounts/skins
    /v2/account/mounts/types
    /v2/account/novelties
    /v2/account/outfits
    /v2/account/pvp/heroes
    /v2/account/raids
    /v2/account/recipes
    /v2/account/titles
    /v2/account/wallet
    /v2/account/worldbosses
  ].freeze

  def new
    session.clear
    session[:stage] = 1
  end

  def token
    @stage = 2
    tokeninfo = Gw2api.tokeninfo(params[:base_api_token])
    if tokeninfo.nil?
      flash.now[:stage_1] = 'Invalid API key!'
    else
      session[:api_token] = params[:base_api_token]
      session[:token_permissions] = tokeninfo['permissions'].sort
      session[:stage] = 2
    end
    render :new
  end

  def permissions
    session[:stage] = 3
    session[:set_permissions] = ['account']
    ALL_PERMISSIONS.each do |perm|
      session[:set_permissions] << perm if params[perm].present?
    end
    session[:set_permissions].uniq!
    session[:set_permissions].sort!

    if session[:set_permissions].empty?
      flash.now[:stage_2] = 'You must select at least one permission!'
    end

    @known_endpoints = KNOWN_ENDPOINTS
    render :new
  end

  def urls
    urls = []
    unless params[:all_endpoints].present?
      params.each do |k, v|
        next unless v.is_a?(String) && k.starts_with?('known-')

        idx = k[6..].to_i
        urls << KNOWN_ENDPOINTS[idx] unless idx > KNOWN_ENDPOINTS.count
      end

      custom = params[:custom_urls]
      urls |= custom.split("\r\n") if custom&.present?

      if urls.empty?
        flash.now[:stage_4] = 'You deselected "Enable All URLs", but did not select any endpoints. All endpoints will be available.'
      end
    end

    session[:stage] = 4
    session[:set_urls] = urls.uniq.sort

    @default_expiry = 30.days.from_now.strftime('%Y-%m-%d %H:%M:%S')

    render :new
  end

  def expiry
    expiry = params[:expiry]
    expiry = nil if expiry.blank?

    token_params = {
      access_token: session[:api_token],
      permissions: session[:set_permissions].join(',')
    }

    if session[:set_urls].count > 0
      token_params[:urls] = session[:set_urls].join(',')
    end

    if expiry
      token_params[:expire] = DateTime.parse(expiry).iso8601(6)
    end

    data = Gw2api.createsubtoken(token_params)
    @subtoken = data['subtoken']

    session.clear
    session[:stage] = 5
    render :new
  end
end
