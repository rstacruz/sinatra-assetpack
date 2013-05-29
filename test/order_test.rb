require File.expand_path('../test_helper', __FILE__)

class OrderTest < UnitTest
  class App < Main
    assets {
      css :a, '/css/a.css', [
        '/css/s*.css',
        '/css/j*.css'
      ]
    }
  end

  test "order" do
    paths = App.assets.packages['a.css'].paths
    assert_equal paths.sort,
      [ "/css/screen.css", "/css/sqwishable.css", "/css/style.css", "/css/stylus.css", "/css/js2c.css" ].sort
  end
end
