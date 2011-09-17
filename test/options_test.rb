require File.expand_path('../test_helper', __FILE__)

class OptionsTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets {
      css :application, [ '/css/*.css' ]
      js_compression :closure
    }
  end

  def app
    App
  end

  test "options" do
    assert App.assets.js_compression == :closure
    assert App.assets.packages['application.css'].path == "/assets/application.css"
  end
end
