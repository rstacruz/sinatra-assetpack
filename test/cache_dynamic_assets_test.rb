require File.expand_path('../test_helper', __FILE__)

class CacheDynamicAssetTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

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
    
    # Ensure that file is not read during second request by overwriting File.read
    real_read = File.method(:read)
    File.send(:define_singleton_method, :read, Proc.new{ |x|
      raise "this should not be called"
    })
    assert_raise(RuntimeError) { File.read(File.dirname(__FILE__)) }
    
    get '/css/screen.css'
    assert last_response.status == 200
    
    File.send(:define_singleton_method, :read, &real_read)
  end

end
