require File.expand_path('../test_helper', __FILE__)

class AppTest < UnitTest
  test 'encoding' do
    app.set :reload_templates, false
    get '/js/encoding.js'
  end
end