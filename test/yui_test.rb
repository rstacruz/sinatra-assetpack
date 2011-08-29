require File.expand_path('../test_helper', __FILE__)

class YuiTest < UnitTest
  setup do
    app.assets.js_compression  = :yui
    app.assets.css_compression = :yui
  end

  teardown do
    app.assets.js_compression  = :jsmin
    app.assets.css_compression = :sass
  end

  test "build" do
    Sinatra::AssetPack::Compressor.expects(:sys).returns("LOL")
    get '/js/app.js'
    assert body == "LOL"
  end
end
