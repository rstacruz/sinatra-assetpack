require File.expand_path('../test_helper', __FILE__)

class CacheTest < UnitTest
  test "Compressed js caching" do
    app.set :reload_templates, false
    app.stubs(:clear_tilt_cache).returns(false)  # return false each time it calls after the first time.
    app.expects(:clear_tilt_cache).returns(true).times(1) # clear cache one time.
    
    JSMin.expects(:minify).times(1).returns ""
    3.times { get '/js/app.js' }
  end
end
