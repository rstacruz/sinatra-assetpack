require File.expand_path('../test_helper', __FILE__)

class CompressedTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets {
      cache_unmodified_dynamic_assets true
      
      js :app, '/app.js', [ '/js/*.js' ]
    }
  end

  def app
    App
  end

  test "asset is served on first attempt with dynamic asset caching" do
    get '/js/hi.js'
    assert last_response.status == 200
  end

  test "asset is served on second attempt with dynamic asset caching" do
    get '/js/hi.js'
    get '/js/hi.js'
    assert last_response.status == 200
  end

end
