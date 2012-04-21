require File.expand_path('../test_helper', __FILE__)

class NoneEngineTest < UnitTest
  setup do
    app.assets.css_compression :none
    app.assets.js_compression :none
  end

  teardown do
    app.assets.css_compression :simple
    app.assets.js_compression :jsmin
  end

  test "build CSS without compressing" do
    get '/css/sq.css'
    assert body.include?(File.read(r('app/css/squishable.css')).strip)
  end

  test "build CSS without compressing" do
    get '/js/app.js'
    assert body.include?(File.read(r('app/js/hi.js')).strip)
  end
end
