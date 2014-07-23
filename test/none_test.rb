require File.expand_path('../test_helper', __FILE__)

class NoneEngineTest < UnitTest
  setup do
    app.set :reload_templates, true
    app.assets.js_compression :none
    app.assets.css_compression :none
  end

  teardown do
    app.assets.js_compression :jsmin
    app.assets.css_compression :simple
  end

  test "build CSS without compressing" do
    get '/css/sq.css'
    assert body.include?(File.read(r('app/css/sqwishable.css')).strip)
  end

  test "build Javascript without compressing" do
    get '/js/hello.js'
    assert body.include?(File.read(r('app/js/hello.js')).strip)
  end
end
