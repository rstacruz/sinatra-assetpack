require File.expand_path('../test_helper', __FILE__)

class SqwishTest < UnitTest
  setup do
    app.set :reload_templates, true
    app.assets.css_compression :sqwish, :strict => true
  end

  teardown do
    app.assets.css_compression :simple
    app.assets.css_compression_options.delete :strict
  end

  def self.sqwish?
    `which sqwish` && true rescue false
  end

  test "css compression options" do
    assert app.assets.css_compression_options[:strict] == true
  end

  if sqwish?
    test "build" do
      swqished_css = '#bg{background:green;color:red}'
      Sinatra::AssetPack::SqwishEngine.any_instance.expects(:css).returns swqished_css
      get '/css/sq.css'
      assert body == swqished_css
    end
  else
    puts "(No Sqwish found; skipping sqwish tests)"
  end
end
