require File.expand_path('../test_helper', __FILE__)

class TemplateCacheTest < UnitTest
  class App < Main
    set :reload_templates, false
    assets do |a|
      a.css :a, '/a.css', %w[/css/screen.css]
    end
  end

  def app
    App
  end

  test "cache dynamic files when reload templates is false" do
    App.any_instance.expects(:asset_filter_css).times(1).returns "OK"
    10.times { get '/css/screen.css' }
  end

  test "cache static css files when reload templates is false" do
    App.any_instance.expects(:asset_filter_css).times(1).returns "OK"
    10.times { get '/css/style.css' }
  end

  test "cache packages when reload templates is false" do
    Sinatra::AssetPack::Package.any_instance.expects(:minify).times(1).returns "OK"
    10.times { get '/a.css' }
  end
end
