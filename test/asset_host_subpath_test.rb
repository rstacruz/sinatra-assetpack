require File.expand_path('../test_helper', __FILE__)

class AssetHostSubpathTest < UnitTest
  class App < Main
    assets {
      serve '/css',     :from => 'app/css'
      serve '/js',      :from => 'app/js'
      serve '/images',  :from => 'app/images'

      asset_hosts ['//cdn-0.example.org']

      css :application, '/css/application.css', ['/css/style.css']
      js :application, '/js/application.js', ['/js/stye.js']
    }

    get('/helper/img') { img '/images/background.jpg' }
  end

  def app
    Rack::URLMap.new('/subpath' => App)
  end

  test "helpers css (mounted on a host and subpath, production)" do
    App.settings.stubs(:environment).returns(:production)
    get '/subpath/helpers/css'

    assert body =~ %r{link rel='stylesheet' href='//cdn-0.example.org/subpath/css/application.[a-f0-9]{32}.css' media='screen'}
  end

  test "helpers img (mounted on a hsot and subpath, production)" do
    App.settings.stubs(:environment).returns(:production)
    get '/subpath/helpers/email'

    assert body =~ %r{src='//cdn-0.example.org/subpath/images/email.[a-f0-9]{32}.png'}
  end

  test "host and subpath get added to css image path in production" do
    app.stubs(:development?).returns(false)
    get 'subpath/css/style.css'
    assert body =~ /background: url\(\/\/cdn-[0|1].example.org\/subpath\/images\/background.[a-f0-9]{32}.jpg\)/
    # Does not alter not served assets
    assert body.include?('background: url(/images/404.png)')
  end
end
