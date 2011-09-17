require File.expand_path('../test_helper', __FILE__)

class ArityTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets do |a|
      a.css :a, '/css/a.css', [
        '/css/s*.css',
        '/css/j*.css'
      ]

      a.js_compression :closure
      a.css_compression = :yui
    end
  end

  test "arity in #assets" do
    paths = App.assets.packages['a.css'].paths
    assert_equal paths,
      [ "/css/screen.css", "/css/sqwishable.css", "/css/style.css", "/css/stylus.css", "/css/js2c.css" ]

    assert App.assets.js_compression == :closure
    assert App.assets.css_compression == :yui
  end
end
