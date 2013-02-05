require File.expand_path('../test_helper', __FILE__)

class CompressedTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets {
      js :app, '/app.js', [ '/js/*.js' ]
    }
  end

  def app
    App
  end

  test "ha" do
    get '/x/y/z/app.js'
    assert last_response.status == 404
  end

  test "right" do
    get '/app.js'
    assert last_response.status == 200
  end

  test "lol" do
    get '/app.b1946ac92492d2347c6235b4d2611184.js'
    assert last_response.status == 200
  end
end
