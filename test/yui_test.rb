require File.expand_path('../test_helper', __FILE__)

class YuiTest < UnitTest
  setup do
    app.set :reload_templates, true
    app.assets.js_compression  = :yui
    app.assets.css_compression = :yui
  end

  teardown do
    app.assets.js_compression  = :jsmin
    app.assets.css_compression = :simple
  end

  test "build" do
    require 'yui/compressor'
    YUI::JavaScriptCompressor.any_instance.expects(:compress).returns "LOL"

    get '/js/app.js'
    assert body == "LOL"
  end
end
