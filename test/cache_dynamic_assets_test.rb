require File.expand_path('../test_helper', __FILE__)

class CacheDynamicAssetTest < UnitTest
  class App < Main
    set :reload_templates, true
  end

  def app
    App
  end

  test "served from cache" do
    app.assets.cache_dynamic_assets = true
    Sinatra::AssetPack::Css.stubs(:preproc).times(1)
    get '/css/screen.css'
    get '/css/screen.css'
    get '/css/screen.css'
    assert last_response.status == 200
  end

  test "not served from cache when disable" do
    app.assets.cache_dynamic_assets = false
    Sinatra::AssetPack::Css.stubs(:preproc).times(3)
    get '/css/screen.css'
    get '/css/screen.css'
    get '/css/screen.css'
    assert last_response.status == 200
  end

end
