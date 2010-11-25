require 'sinatra/base'

class Application < Sinatra::Base
  
  get 'pulse' do
    '1'
  end
end