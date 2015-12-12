require File.expand_path('../test_helper', __FILE__)

class AssetDynamicHostTest < UnitTest
  class App < Main
    assets {
      serve '/css',     :from => 'app/css'
      serve '/js',      :from => 'app/js'
      serve '/images',  :from => 'app/images'

      asset_hosts ->(request) {
        [
          "//cdn-0.#{request.host}",
          "//cdn-1.#{request.host}",
        ]
      }

      css :a, ["/css/style.css"]
      js :b, ["/js/hello.js"]
    }

    get('/helper/img') { img '/images/background.jpg' }
  end

  def app
    App
  end

  test "hosts sets option" do
    assert app.assets.asset_hosts.is_a?(Proc)
  end

  test "host gets added to css source path" do
    app.stubs(:development?).returns(false)
    assert(
      App.assets.packages['a.css'].to_production_html(
        Sinatra::Request.new({'HTTP_HOST' => 'test.com:80'})
      ) =~ %r{href='//cdn-[0|1].test.com/assets/a.[a-f0-9]{32}.css'}
    )
  end

  test "host gets added to js source path" do
    app.stubs(:development?).returns(false)
    assert(
      App.assets.packages['b.js'].to_production_html(
        Sinatra::Request.new({'HTTP_HOST' => 'test.com:80'})
      ) =~ %r{src='//cdn-[0|1].test.com/assets/b.[a-f0-9]{32}.js'}
    )
  end

  test "host gets added to image helper path in production" do
    app.stubs(:development?).returns(false)
    get '/helper/img', {}, {'HTTP_HOST' => 'test.com:80'}
    assert body =~ /<img src='\/\/cdn-[0|1].test.com\/images\/background.[a-f0-9]{32}.jpg' \/>/
  end

  test "host doesn't get added to image helper path in development" do
    app.stubs(:development?).returns(true)
    get '/helper/img', {}, {'HTTP_HOST' => 'test.com:80'}
    assert body =~ /<img src='\/images\/background.jpg' \/>/
    assert body =~ /<img src='\/images\/background.jpg' \/>/
  end

  test "host gets added to css image path in production" do
    app.stubs(:development?).returns(false)
    get '/css/style.css', {}, {'HTTP_HOST' => 'test.com:80'}
    assert body =~ /background: url\(\/\/cdn-[0|1].test.com\/images\/background.[a-f0-9]{32}.jpg\)/
    # Does not alter not served assets
    assert body.include?('background: url(/images/404.png)')
  end

  test "host gets added to css package image path in production" do
    app.stubs(:development?).returns(false)
    get '/assets/a.css', {}, {'HTTP_HOST' => 'test.com:80'}
    assert body =~ /background:url\(\/\/cdn-[0|1].test.com\/images\/background.[a-f0-9]{32}.jpg\)/
    # Does not alter not served assets
    assert body.include?('background:url(/images/404.png)')
  end

  test "do not add asset host to filename in dev mode" do
    app.stubs(:development?).returns(true)
    file = '/js/hello.js'
    assert !(
           Sinatra::AssetPack::HtmlHelpers.get_file_uri(
             file, App.assets,Sinatra::Request.new({'HTTP_HOST' => 'test.com:80'})
           ) =~ /cdn-[0|1].test.com/)
  end

  test "add asset host to filename in production/qa mode" do
    app.stubs(:development?).returns(false)
    file = '/js/hello.js'
    assert (Sinatra::AssetPack::HtmlHelpers.get_file_uri(
             file, App.assets, Sinatra::Request.new({'HTTP_HOST' => 'test.com:80'})
           ) =~ /cdn-[0|1].test.com/)
  end
end
