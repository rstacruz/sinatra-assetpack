require File.expand_path('../test_helper', __FILE__)

# tests for running sinatra-assetpack with an application that's mounted under a
# subdirectory
class SubpathTest < UnitTest
  def app
    Rack::URLMap.new('/subpath' => Main)
  end

  test "helpers css (mounted on a subpath, development)" do
    Main.settings.stubs(:environment).returns(:development)
    get '/subpath/helpers/css'
    assert body =~ %r{link rel='stylesheet' href='/subpath/css/screen.[a-f0-9]{32}.css' media='screen'}
  end

  test "helpers css (mounted on a subpath, production)" do
    Main.settings.stubs(:environment).returns(:production)
    get '/subpath/helpers/css'
    assert body =~ %r{link rel='stylesheet' href='/subpath/css/application.[a-f0-9]{32}.css' media='screen'}
  end

  test "helpers img (mounted on a subpath, development)" do
    Main.settings.stubs(:environment).returns(:development)
    get '/subpath/helpers/email'
    assert body =~ %r{src='/subpath/images/email.png'}
  end

  test "helpers img (mounted on a subpath, production)" do
    Main.settings.stubs(:environment).returns(:production)
    get '/subpath/helpers/email'
    assert body =~ %r{src='/subpath/images/email.[a-f0-9]{32}.png'}
  end

  test '/subpath/js/hello.js (plain js)' do
    get '/subpath/js/hello.js'
    assert body == '$(function() { alert("Hello"); });'
  end
end
