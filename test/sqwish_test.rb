require File.expand_path('../test_helper', __FILE__)

class SqwishTest < UnitTest
  setup do
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
      Sinatra::AssetPack::Compressor
      Sinatra::AssetPack::SqwishEngine.any_instance.expects(:css)

      get '/css/sq.css'
    end
  else
    puts "(No Sqwish found; skipping sqwish tests)"
  end
end
