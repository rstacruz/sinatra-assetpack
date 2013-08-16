require File.expand_path('../test_helper', __FILE__)

class CachePackagePathsTest < UnitTest
  class App < Main
    assets {
      serve '/css', :from => 'app/css'
      css :a, [ '/css/**/style*.css' ]
    }

    get('/pkg') { css :a }
  end

  def app
    App
  end

  test "package contents are not cached in development" do
    app.settings.stubs(:environment).returns(:development)
    get '/pkg'
    assert_equal 200, last_response.status
    assert_match %r{css/style\.\w{32}\.css}, body

    begin
      file = Tempfile.new(['style', '.scss'], File.join(File.dirname(__FILE__), "app", "app", "css"))
      file.write("body{color: red;}") 
      file.flush
      
      get '/pkg'
      assert_equal 200, last_response.status
      assert_match %r{css/style\.\w{32}\.css}, body
      assert_match %r{css/#{File.basename(file.path).chomp(".scss")}\.\w{32}\.css}, body

    ensure
      unless file == nil
          file.close 
          file.delete
      end
    end
  end

end
