require File.expand_path('../test_helper', __FILE__)

class CacheDynamicAssetTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    set :reload_templates, true

    assets {
      cache_dynamic_assets true
      
      js :app, '/app.js', [ '/js/*.js' ]
    }
  end

  def app
    App
  end

  test "asset is served on first request with dynamic asset caching" do
    get '/js/hi.js'
    assert last_response.status == 200
  end

  test "asset is served from cache on second request with dynamic asset caching" do
    get '/css/screen.css'
    Sinatra::AssetPack::Css.stubs(:preproc).raises("should not be called")
    get '/css/screen.css'
    assert last_response.status == 200
  end

end
