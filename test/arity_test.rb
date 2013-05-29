require File.expand_path('../test_helper', __FILE__)

class ArityTest < UnitTest
  class App < Main
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
    expect = [ "/css/screen.css", "/css/sqwishable.css", "/css/style.css", "/css/stylus.css", "/css/js2c.css" ]
    if RUBY_VERSION < "1.9"
      # In 1.8.7 glob returns inconsitent files order so just check array are equivalents
      assert_equal expect.size, paths.size
      assert_equal 0, paths.reject{ |p| expect.include?(p) }.size
    else
      assert_equal expect, paths
    end

    assert App.assets.js_compression == :closure
    assert App.assets.css_compression == :yui
  end
end
