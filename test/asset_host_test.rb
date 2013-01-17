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
  end

  test "add asset host to filename" do
		file = File.join(app.root, 'app/js/hello.js')

  	assert Sinatra::AssetPack::HtmlHelpers.get_file_uri(file, App.assets).include? 'cdn-0.example.org'
  end
end