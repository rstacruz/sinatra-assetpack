require File.expand_path('../test_helper', __FILE__)

class IgnoreTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets do
      js :main, '/main.js', %w[/js/*.js]
    end
  end

  def app
    App
  end

  test "ignore as individual file" do
    get '/js/_ignoreme.js'
    assert last_response.status == 404
  end

  test "ignore in package" do
    get '/main.js'
    assert body.size > 0
    assert !body.include?("BUMBLEBEE")
  end

  test "package files" do
    assert !app.assets.packages['main.js'].files.any? { |s| s.include? '_ignoreme.js' }
  end
end
