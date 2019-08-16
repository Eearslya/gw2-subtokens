Rails.application.routes.draw do
  root 'subtokens#new'

  get '/', to: 'subtokens#new'
  post '/token', to: 'subtokens#token', as: 'token'
  post '/permissions', to: 'subtokens#permissions', as: 'permissions'
  post '/urls', to: 'subtokens#urls', as: 'urls'
  post '/expiry', to: 'subtokens#expiry', as: 'expiry'
end
