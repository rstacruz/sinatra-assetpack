require File.expand_path('../test_helper', __FILE__)

class CacheTest < UnitTest
  test "Compressed js caching" do
    app.set :reload_templates, false
    JSMin.expects(:minify).times(1).returns ""
    3.times { get '/js/app.js' }
  end
end
