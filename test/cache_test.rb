require File.expand_path('../test_helper', __FILE__)

class CacheTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    set :reload_templates, false
    assets {
      js :app, '/js/app.js', [
        '/js/vendor/**/*.js',
        '/js/assets/**/*.js',
        '/js/hi.js',
        '/js/hell*.js'
      ]
      js_compression :jsmin
    }
  end

  def app() App; end

  test "Compressed js caching" do
    app.set :reload_templates, false
    app.stubs(:clear_tilt_cache).returns(false)  # return false each time it calls after the first time.
    app.expects(:clear_tilt_cache).returns(true).times(1) # clear cache one time.

    JSMin.expects(:minify).times(1).returns ""
    3.times { get '/js/app.js' }
  end
end
