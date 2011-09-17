require File.expand_path('../test_helper', __FILE__)

class NonExistentTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets do |a|
      a.js :script, '/script.min.js', [
        '/js/h*.js',
        '/js/combine.js'
      ]

      a.js_compression :closure
      a.css_compression = :yui
    end

    get '/js/combine.js' do
      "alert('Spin spin sugar');"
    end

    get '/' do
      js :script
    end
  end

  def app
    App
  end

  test "non-existent files in js helper" do
    get '/'
    assert body.include?('combine.js')
  end

  test "dev non-existent files in js helper" do
    App.expects(:environment).returns(:development).times(1..100)
    get '/'
    assert body.include?('combine.js')
  end

  test "non-existent files in js minifier" do
    get '/script.min.js'
    assert body.include?('Spin spin sugar')
  end
end
