require File.expand_path('../test_helper', __FILE__)


class OptionsTest < UnitTest
  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)
    register Sinatra::AssetPack

    assets {
      js_compression :closure
    }
  end

  test "options" do
    assert App.assets.js_compression == :closure
  end
end
