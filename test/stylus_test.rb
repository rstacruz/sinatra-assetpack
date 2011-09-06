require File.expand_path('../test_helper', __FILE__)

class StylusTest < UnitTest
  class App < Sinatra::Base
    set :root, File.expand_path('../app', __FILE__)
    register Sinatra::AssetPack

    assets do |a|
      a.css :a, '/css/a.css', [
        '/css/stylus.css'
      ]
    end
  end

  def app
    App
  end

  def self.stylus?
    `which stylus` && true rescue false
  end

  if stylus?
    test "build" do
      get '/css/stylus.css'
      assert body.gsub(/[ \t\r\n]/, '') == "body{background:#f00;color:#00f;}"
    end

  else
    puts "(No Stylus found; skipping stylus tests)"
  end
end
