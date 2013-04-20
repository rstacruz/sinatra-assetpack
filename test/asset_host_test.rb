require File.expand_path('../test_helper', __FILE__)

class AssetHostTest < UnitTest
  class TestApp < UnitTest::App
    register Sinatra::AssetPack

    set :root, File.join(File.dirname(__FILE__), "app")

    assets {
      serve '/css',     :from => 'app/css'
      serve '/js',      :from => 'app/js'
      serve '/images',  :from => 'app/images'

      asset_hosts [
        '//cdn-0.example.org',
        '//cdn-1.example.org'
      ]

      css :a, ["/css/style.css"]
      js :b, ["/js/hello.js"]
    }

    get('/helper/img') { img '/images/background.jpg' }
  end

  def app
    TestApp
  end

  test "hosts sets option" do
    assert app.assets.asset_hosts.include? '//cdn-0.example.org'
    assert app.assets.asset_hosts.include? '//cdn-1.example.org'
  end

  test "host gets added to css source path" do
    app.stubs(:development?).returns(false)
    assert TestApp.assets.packages['a.css'].to_production_html =~ %r{href='//cdn-[0|1].example.org/assets/a.[a-f0-9]{32}.css'}
  end

  test "host gets added to js source path" do
    app.stubs(:development?).returns(false)
    assert TestApp.assets.packages['b.js'].to_production_html =~ %r{src='//cdn-[0|1].example.org/assets/b.[a-f0-9]{32}.js'}
  end

  test "host gets added to image helper path in production" do
    app.stubs(:development?).returns(false)
    get '/helper/img'
    assert body =~ /<img src='\/\/cdn-[0|1].example.org\/images\/background.[a-f0-9]{32}.jpg' \/>/
  end

  test "host doesn't get added to image helper path in development" do
    app.stubs(:development?).returns(true)
    get '/helper/img'
    assert body =~ /<img src='\/images\/background.jpg' \/>/
  end

  test "host gets added to css image path in production" do
    app.stubs(:development?).returns(false)
    get '/css/style.css'
    assert body.include?('background: url(//cdn-1.example.org/images/background.b1946ac92492d2347c6235b4d2611184.jpg)')

    # does not alter non-existing files (design or flaw???)
    assert body.include?('background: url(/images/404.png)')
  end

  test "do not add asset host to filename in dev mode" do
    app.stubs(:development?).returns(true)
    file = '/js/hello.js'
    assert !(Sinatra::AssetPack::HtmlHelpers.get_file_uri(file, TestApp.assets) =~ /cdn-[0|1].example.org/)
  end

  test "add asset host to filename in production/qa mode" do
    app.stubs(:development?).returns(false)
    file = '/js/hello.js'
    assert Sinatra::AssetPack::HtmlHelpers.get_file_uri(file, TestApp.assets) =~ /cdn-[0|1].example.org/
  end
end
