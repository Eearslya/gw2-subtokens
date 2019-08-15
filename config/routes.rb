Rails.application.routes.draw do
  root 'subtokens#new'

  get 'subtokens/new'
  get 'subtokens/create'
end
