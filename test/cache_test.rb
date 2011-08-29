require File.expand_path('../test_helper', __FILE__)

class CacheTest < UnitTest
  test "Compressed js caching" do
    app.assets.reset_cache
    # JSMin.expects(:minify).times(1) -- not working?
    get '/js/app.js'
    get '/js/app.js'
  end
end
