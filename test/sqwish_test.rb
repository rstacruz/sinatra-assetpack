require File.expand_path('../test_helper', __FILE__)

class Sqwish < UnitTest
  setup do
    app.assets.css_compression = :sqwish
    app.assets.css_compression_options[:strict] = true
  end

  teardown do
    app.assets.css_compression = :simple
    app.assets.css_compression_options.delete :strict
  end

  def self.sqwish?
    `which sqwish` && true rescue false
  end

  if sqwish?
    test "build" do
      get '/css/sq.css'
      assert body.include?('background:green;color:red')
    end
  else
    puts "(No Sqwish found; skipping sqwish tests)"
  end
end
