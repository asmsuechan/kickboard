Rails.application.routes.draw do
  root controller: 'attachments', action: 'new'
  resources :attachments, except: [:edit, :delete]
  post 'attachments/rollback'
  post 'attachments/create_zip'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
