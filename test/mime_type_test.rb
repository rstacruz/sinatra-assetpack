require File.expand_path('../test_helper', __FILE__)

class AppTest < UnitTest
  test 'htc' do
    get '/css/behavior.htc'
    assert last_response.content_type =~ %r[^text/x-component]
  end

  test 'css - sass' do
    get '/css/screen.css'
    assert last_response.content_type =~ %r[^text/css]
  end

  test 'js' do
    get '/js/hello.js'
    assert last_response.content_type =~ %r[^.*?/javascript]
  end

  test 'js - coffee' do
    get '/js/hi.js'
    assert last_response.content_type =~ %r[^.*?/javascript]
  end

  test 'css - compressed' do
    get '/css/application.css'
    assert last_response.content_type =~ %r[^text/css]
  end

  test 'js - compressed' do
    get '/skitch.js'
    assert last_response.content_type =~ %r[^.*?/javascript]
  end

  test 'eot' do
    get '/fonts/cantarell-regular-webfont.eot'
    assert last_response.content_type =~ %r[^application/vnd.ms-fontobject]
  end

  test 'svg' do
    get '/fonts/cantarell-regular-webfont.svg'
    assert last_response.content_type =~ %r[^image/svg\+xml]
  end

  test 'ttf' do
    get '/fonts/cantarell-regular-webfont.ttf'
    assert last_response.content_type =~ %r[^application/octet-stream]
  end

  test 'woff' do
    get '/fonts/cantarell-regular-webfont.woff'
    assert last_response.content_type =~ %r[^application/font-woff]
  end
end
