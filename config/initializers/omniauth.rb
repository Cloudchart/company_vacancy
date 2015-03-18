Rails.application.config.middleware.use OmniAuth::Builder do

  provider :developer unless Rails.env.production?
  provider :twitter, 'kDU1Ovpa0WeAdy5AYhPFypVzj', 'giGFkq2JDigICnbVg9w5MkidTrhleUzXzEvQEMzaZjl9haPpct'

end
