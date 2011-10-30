require File.expand_path('../test_helper', __FILE__)

class AssetHostTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets { 
      asset_hosts [
        '//cdn-0.example.org',
        '//cdn-1.example.org'
    	]	      
    }

    get('/helper/img') { img '/images/foo.jpg' }
  end

  def app
    App
  end

  test "host sets option" do
    assert_equal 'cdn.example.org', app.assets.host
  end

  test "host gets added to css source path" do
    assert App.assets.packages['a.css'].to_production_html =~ %r{href='//cdn.example.org/assets/a.[a-f0-9]+.css'}
  end

  test "host gets added to js source path" do
    assert App.assets.packages['b.js'].to_production_html =~ %r{src='//cdn.example.org/assets/b.[a-f0-9]+.js'}
  end

  test "host gets added to image helper path in production" do
    app.stubs(:production?).returns(true)
    get '/helper/img'
    assert_equal "<img src='//cdn.example.org/images/foo.jpg' />", body 
  end

  test "host doesn't get added to image helper path in development" do
    app.stubs(:production?).returns(false)
    get '/helper/img'
    assert_equal "<img src='/images/foo.jpg' />", body 
  end

  test "host gets added to css image path in production" do
    app.stubs(:production?).returns(true)
    get '/css/style.css'
    assert body.include?('background: url(//cdn.example.org/images/404.png)')
  end

  test "add asset host to filename" do
    file = File.join(app.root, 'app/js/hello.js')

  	assert Sinatra::AssetPack::HtmlHelpers.get_file_uri(file, App.assets).include? 'cdn-0.example.org'
  end
end
