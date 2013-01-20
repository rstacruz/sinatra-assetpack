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
    JSMin.expects(:minify).times(1).returns ""
    3.times { get '/js/app.js' }
  end
end
