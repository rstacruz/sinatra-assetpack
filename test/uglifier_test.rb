require File.expand_path('../test_helper', __FILE__)

class UglifyTest < UnitTest
  class App < Main
    assets do
      js_compression :uglify, :mangle => true
      js :main, '/main.js', [
        '/js/ugly.js'
      ]
    end
  end

  def app
    App
  end

  test "build" do
    get '/main.js'
    assert !body.include?("noodle")
  end
end
