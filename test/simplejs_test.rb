require File.expand_path('../test_helper', __FILE__)

class SimplejsTest < UnitTest
  setup do
    app.set :reload_templates, true
    app.assets.js_compression = :simple
  end

  teardown do
    app.assets.js_compression  = :jsmin
  end

  test "build" do
    get '/js/app.js'
    assert body.include? ");\n\n$(function("
  end
end
