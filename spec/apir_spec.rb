require 'spec_helper'
require 'webmock/rspec'
require 'apir'

WebMock.disable!

valid_json_response_body = JSON.unparse({ response: { key: [1, 2, 3], key_object: { id: 2, string: 'string_value' } } })
html_response            =<<END
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>html{height:100%}body{margin:0 auto;min-height:600px;min-width:800px;height:100%}.top{height:100px;height:calc(40% - 140px)}.bottom{height:150px;height:calc(60% - 210px)}.center{height:350px;text-align:center;vertical-align:middle;font-family:Verdana}.circle{margin:auto;width:260px;height:260px;border-radius:50%;background:#c0c6cc}.circle_text{line-height:260px;font-size:100px;color:#ffffff;font-weight:bold}.text{line-height:40px;font-size:26px;color:#505a64}
</style>
</head>
<body>
<div class="top"></div>
<div class="center">
<div class="circle">
<div class="circle_text">403</div>
</div>
<div>
<p class="text" id="a"></p>
</div>
<script>
/* Copyright (c) 2016 Synology Inc. All rights reserved. */

(function(){var a=new XMLHttpRequest();a.open("get","/missing",true);a.send();a.onreadystatechange=function(){if(a.readyState==4&&(a.status==200||a.status==304)){var c=String(a.responseText);var e=document.open("text/html","replace");e.write(c);e.close()}else{var d={en:"There is an error while processing this request.",zh:"\u5904\u7406\u6b64\u8bf7\u6c42\u65f6\u51fa\u73b0\u9519\u8bef\u3002",it:"Errore durante l'elaborazione della richiesta.","zh-HK":"\u60a8\u6240\u6307\u5b9a\u7684\u9801\u9762\u767c\u751f\u932f\u8aa4\u3002",cs:"Do\u0161lo k\u00a0chyb\u011b p\u0159i zpracov\u00e1n\u00ed tohoto po\u017eadavku.",es:"Se ha producido un error al procesar esta solicitud.",ru:"\u041f\u0440\u0438 \u043e\u0431\u0440\u0430\u0431\u043e\u0442\u043a\u0435 \u044d\u0442\u043e\u0433\u043e \u0437\u0430\u043f\u0440\u043e\u0441\u0430 \u0432\u043e\u0437\u043d\u0438\u043a\u043b\u0430 \u043e\u0448\u0438\u0431\u043a\u0430.",nl:"Er is een fout opgetreden tijdens deze aanvraag.",pt:"Ocorreu um erro ao processar este pedido.",no:"Det oppsto en feil under behandlingen av denne foresp\u00f8rselen.",nb:"Det oppsto en feil under behandlingen av denne foresp\u00f8rselen.",tr:"Bu iste\u011fi i\u015flerken bir hata meydana geldi.",pl:"Wyst\u0105pi\u0142 b\u0142\u0105d podczas przetwarzania tego \u017c\u0105dania.",fr:"Une erreur s'est produite lors du traitement de cette demande.",de:"Bei der Verarbeitung dieser Anforderung ist ein Fehler aufgetreten.",hu:"Hiba t\u00f6rt\u00e9nt a k\u00e9r\u00e9s feldolgoz\u00e1sa sor\u00e1n.","pt-BR":"Houve um erro ao processar esta solicita\u00e7\u00e3o.","zh-MO":"\u60a8\u6240\u6307\u5b9a\u7684\u9801\u9762\u767c\u751f\u932f\u8aa4\u3002",da:"Der er en fejl under behandling af denne anmodning.",ja:"\u3053\u306e\u8981\u8acb\u3092\u51e6\u7406\u3057\u3066\u3044\u308b\u9593\u306b\u30a8\u30e9\u30fc\u304c\u767a\u751f\u3057\u307e\u3057\u305f\u3002",nn:"Det oppsto en feil under behandlingen av denne foresp\u00f8rselen.","zh-TW":"\u60a8\u6240\u6307\u5b9a\u7684\u9801\u9762\u767c\u751f\u932f\u8aa4\u3002",ko:"\uc774 \uc694\uccad\uc744 \ucc98\ub9ac\ud558\ub294 \ub3d9\uc548 \uc624\ub958\uac00 \ubc1c\uc0dd\ud588\uc2b5\ub2c8\ub2e4.",sv:"Det blev ett fel n\u00e4r beg\u00e4ran bearbetades."};var b=["zh-TW","zh-HK","zh-MO","pt-BR"];var f;if(window.navigator.languages!==undefined){f=window.navigator.languages[0]}else{f=window.navigator.language||window.navigator.browserLanguage}if(b.indexOf(f)<0){f=f.split("-")[0]}document.getElementById("a").innerHTML=d[f]||d.enu}}})();
</script>
</div>
<div class="bottom"></div>
</body>
</html>

END
no_response = nil

requests = [
    [200, 'https://200.contoso.com', valid_json_response_body],
    [503, 'https://503.contoso.com', html_response],
    [404, 'https://404.contoso.com', no_response],
]

mirror_data = 'https://mirrored.com'

RSpec.configure do |config|
  config.before(:each) do
    requests.each do |code, url, body|
      stub_request(:any, url).
          to_return(status: code, body: body)
    end


    stub_request(:any, /#{mirror_data}/).
        to_return { |request| { body: request.body, headers: request.headers } }
  end
end


describe Apir::Request do
  before(:all) do
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after(:all) do
    WebMock.allow_net_connect!
    WebMock.disable!
  end

  let(:request) { Apir::Request.new(current_url) }

  context 'default state' do
    let(:current_url) { requests[0][1] }

    describe 'responds to' do

      it '#get!' do
        expect(request).respond_to?(:get!)
      end

      it '#post!' do
        expect(request).respond_to?(:post!)
      end

      it 'redo!' do
        expect(request).respond_to?(:redo!)
      end

      it 'get! returns self' do
        expect(request.get!).to eq(request)
      end

      it 'post! returns self' do
        expect(request.get!).to eq(request)
      end

    end

    describe 'default properties' do
      it '#response' do
        expect(request.response).to be_nil
      end

      it '#body' do
        expect(request.body).to be_nil
      end

      it '#cookie_jar' do
        expect(request.cookie_jar).to be_empty
      end

      it '#headers' do
        expect(request.headers).to be_empty
      end

      it '#params' do
        expect(request.params).to be_empty
      end

      it '#type' do
        expect(request.type).to be nil
      end

      it '#uri' do
        expect(request.uri.to_s).to include current_url
      end

      it '#query' do
        expect(request.query).to be nil
      end

      it '#method' do
        expect(request.method).to eq current_url
      end

      it '#body_type' do
        expect(request.body_type).to be nil
      end

      it '#time_taken' do
        expect(request.time_taken).to be nil
      end

      it '#request_time' do
        expect(request.request_time).to be nil
      end

      it '#raw_request' do
        expect(request.raw_request).to be nil
      end

      it '#raw_response' do
        expect(request.raw_response).to be nil
      end

      it '#authorisation' do
        expect(request.authorisation).to be_empty
      end

      it '#report_data' do
        expect(request.report_data).to be_a(String)
      end

      it '#curl' do
        expect(request.curl).to include current_url
      end

    end

  end

  context '200 json response' do
    let(:current_url) { requests[0][1] }

    it 'get! response is json with keys' do
      request.get!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
    end

    it 'post! response is json with keys' do
      request.post!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
    end

    it 'redo! get' do
      request.get!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
      request.redo!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
    end

  end

  context '200 non-json response' do
    let(:current_url) { mirror_data }

    it 'post! response is json with keys' do
      request.body = html_response
      request.post!
      expect(request.response).to be nil
    end

    it 'redo! post' do
      request.body = valid_json_response_body
      request.post!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
      request.redo!
      expect(request.response).to eq JSON.parse(valid_json_response_body, symbolize_names: true)
    end

  end

  context '401' do
    let(:current_url) { requests[2][1] }

    it 'not raise exception' do
      expect { request.get! }.not_to raise_error
    end

  end

  context '503' do
    let(:current_url) { requests[1][1] }

    it 'raise exception' do
      expect { request.get! }.to raise_error(RuntimeError)
    end

  end

  describe 'cookies' do
    let(:current_url) { requests[0][1] }

    it 'request cookies is a cookie jar' do
      expect(request.cookie_jar).to be_a(HTTP::CookieJar)
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'test',
                                             domain: '.contoso.com',
                                             path:   '/')
      expect(request.cookie_jar.to_a.size).to eq(1)
    end

    it 'response cookies is a cookie jar' do
      request.get!
      expect(request.raw_response.cookie_jar).to be_a(HTTP::CookieJar)
    end

    it 'cookies persists' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'test',
                                             domain: '.contoso.com',
                                             path:   '/')
      request.get!
      request.redo!
      expect(request.raw_response.cookies).to include('referrer' => 'test')
    end

    it 'cookie jar to hash' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'test',
                                             domain: '.contoso.com',
                                             path:   '/')
      request.get!
      expect(request.cookies).to include('referrer' => 'test')
    end

  end

  describe 'uri' do

    it 'full url in initialize' do
      r      = Apir::Request.new(mirror_data)
      r.body = 'from init'
      r.post!
      expect(r.raw_response.body).to eq('from init')
    end

  end

  describe 'headers' do
    let(:current_url) { mirror_data }

    it 'default content_type' do
      request.headers = { content_type: 'sucka bliat' }
      expect(request.headers).to include(content_type: 'sucka bliat')
      request.get!
      expect(request.raw_response.headers).to include(content_type: 'sucka bliat')
    end

    it 'intitialize override' do
      request.headers = { header_key: 'header-value' }
      request.get!
      expect(request.raw_response.headers).to include(header_key: 'header-value')

      r = Apir::Request.new(mirror_data, headers: { header_key: 'header-value' })
      r.get!
      expect(r.raw_response.headers).to include({ header_key: 'header-value' })
    end


  end

  describe 'query string' do
    let(:current_url) { 'https://query.com' }

    it 'empty qs params is not stripped' do
      request_params = { key: 'value', another_key: 'another_value', bool: nil }
      stub_request(:any, current_url).
          with(query: request_params).
          to_return { |request| { body: 'OK' } }

      request.query = request_params
      request.get!
      expect(request.raw_response).to eq('OK')
    end


  end

  describe 'timeout' do
    let(:current_url) { 'http://timeout.com' }

    it 'raise runtime exception' do
      stub_request(:any, current_url).to_timeout
      expect { request.get! }.to raise_error(RuntimeError)
    end

  end

  describe 'post body types' do
    let(:current_url) { 'http://bodytypes.com' }

    # bugged nested array
    # it 'hash with array as form data' do
    #   stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
    #
    #   data = { key: 'value', array: [1, 2, 3] }
    #
    #   request.body = data.clone
    #   request.post!(:form_data)
    #   expect(request.raw_response.body).to eq(data.to_query)
    # end

    it 'hash with array as form data' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }

      data = { key: 'value' }

      request.body = data.clone
      request.post!(:form_data)
      expect(request.raw_response.body).to eq(URI.encode_www_form(data))
    end

    it 'hash as json' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }

      data         = { key: 'value', array: [1, 2, 3] }
      request.body = data.clone
      request.post!(:json)
      expect(request.raw_response.body).to eq(JSON.unparse(data))
    end

    it 'hash as string' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }

      data         = { key: 'value', array: [1, 2, 3] }
      request.body = data.clone
      request.post!(:string)
      expect(request.raw_response.body).to eq(data.to_s)
    end

    it 'body as param' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }

      data = { key: 'value', array: [1, 2, 3] }
      r    = Apir::Request.new(current_url, body: data)
      r.post!(:string)
      expect(r.raw_response.body).to eq(data.to_s)
    end

  end

  describe 'curl with post and cookies' do
    let(:current_url) { 'http://curl.com' }

    it 'form data curl' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = { body_hash_key: 'value' }
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'curl_test',
                                             domain: '.curl.com',
                                             path:   '/')
      request.headers[:bitch_data] = 'your mom'
      request.post!(:form_data)
      expect(request.curl).to include(current_url)
      expect(request.curl).to include("-H 'bitch_data: your mom'")
      expect(request.curl).to include('referrer=curl_test')
      expect(request.curl).to include('body_hash_key=value')
    end

    it 'json curl' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = { body_hash_key: 'value' }
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'curl_test',
                                             domain: '.curl.com',
                                             path:   '/')
      request.headers[:bitch_data] = 'your mom'
      request.post!(:json)
      expect(request.curl).to include(current_url)
      expect(request.curl).to include("-H 'bitch_data: your mom'")
      expect(request.curl).to include('referrer=curl_test')
      expect(request.curl).to include('"body_hash_key":"value"')
    end

    it 'exact json curl' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = { my_key: 'value' }
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'curl_test',
                                             domain: '.curl.com',
                                             path:   '/')
      request.headers[:bitch_data] = 'your mom'
      request.post!(:json)

      expected_curl = %q(curl 'http://curl.com' -H 'bitch_data: your mom' -H 'cookie: referrer=curl_test;' --data '{"my_key":"value"}' -i)
      expect(request.curl).to eq(expected_curl)
    end
  end

  describe 'files attachments' do
    let(:current_url) { 'http://files.com' }

    it 'no response' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.headers = { content_type: 'image/png' }
      request.post!
      expect(request.response).to be(nil)
    end

  end

  describe 'authorisation' do
    let(:current_url) { 'http://auth.com' }

    it 'passed as headers' do
      require 'base64'
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      login                 = 'dota'
      password              = 'sniper'
      request.authorisation = { login: login, password: password }
      base64_auth_string    = Base64.encode64("#{login}:#{password}")
      request.get!
      expect(request.raw_response.headers).to include({ authorization: "Basic #{base64_auth_string.delete("\r\n")}" })
    end

  end

  describe 'reporting' do
    let(:current_url) { 'http://reportdata.com' }
    let(:data) { { key: 'value', array: [1, 2, 3] } }

    it 'on post form data' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = data.clone
      request.post!(:form_data)
      expect(request.report_data).to include(current_url)
    end

    it 'on post form data with no body' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = nil
      request.post!(:form_data)
      expect(request.report_data).to include(current_url)
    end

    it 'on post json' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = data.clone
      request.post!(:json)
      expect(request.report_data).to include(current_url)
    end

    it 'on post form string' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = data.clone
      request.post!(:string)
      expect(request.report_data).to include(current_url)
    end

    it 'with message' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = data.clone
      request.post!(:string)
      report = request.report_data('my message')
      expect(report).to include(current_url)
      expect(report).to include('my message')
    end

    it 'request time' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.body = 'test'
      request.post!(:string)
      expect(request.report_data).to include('TIME:')
      expect(request.report_data).to include(Time.now.utc.to_s)
    end

    it 'with no value cookie' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.cookie_jar << HTTP::Cookie.new(name:   'empty_value',
                                             value:  '',
                                             domain: '.reportdata.com',
                                             path:   '/')
      request.post!
      expect(request.report_data).to include('empty_value=;')
    end

    it 'presenting cookie jar' do
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'test',
                                             domain: '.contoso.com',
                                             path:   '/')
      expect(Apir::Request.present_cookie_jar(request.cookie_jar)).to include('referrer', 'test')
      request.cookie_jar << HTTP::Cookie.new(name:   'referrer2', value: 'test2',
                                             domain: '.contoso.com',
                                             path:   '/')
      expect(Apir::Request.present_cookie_jar(request.cookie_jar)).to include('referrer=test; referrer2=test2')
    end

    it 'response time' do
      stub_request(:any, current_url).to_return { |request| { body: request.body, headers: request.headers } }
      request.get!
      expect(request.request_time).not_to be_nil
      expect(request.time_taken).to be_a(Numeric)
    end
  end

end