require File.expand_path('../test_helper', __FILE__)

class PreprocTest < UnitTest
  test "preproc" do
    get '/css/screen.css'
    assert body =~ %r{email.[a-f0-9]+.png}
  end

  test "preproc static files" do
    get '/css/style.css'
    assert body =~ %r{background.[a-f0-9]+.jpg}
  end

  test "no cache-busting number for non-existent images" do
    get '/css/style.css'
    assert body.include?('background: url(/images/404.png)')
  end

  test "preproc on minify" do
    get '/css/application.css'
    assert body =~ %r{email.[a-f0-9]+.png}
  end

  test "embed" do
    get '/css/screen.css'
    assert body =~ %r{data:image/png;base64,[A-Za-z0-9=/]{100,}}
  end
end
