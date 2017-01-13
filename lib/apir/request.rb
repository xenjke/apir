require 'addressable/uri'
require 'http-cookie'
require 'rest-client'
require 'json'
require 'date'
require 'active_support/all'

require 'apir/reporting'

module Apir
# класс реквеста
  class Request
    include RequestReporting
    attr_accessor :params
    attr_accessor :type, :uri, :query, :headers, :method, :response, :body, :body_type
    attr_accessor :time_taken, :request_time
    attr_accessor :raw_request, :raw_response
    attr_accessor :cookie_jar
    attr_accessor :authorisation

    def initialize(request_url, **args)
      @method        = request_url
      @params        = args
      @headers       = args[:headers] || {}
      @query         = args[:query]
      @cookie_jar    = HTTP::CookieJar.new
      @authorisation = {}
      @body          = args[:body]
    end

    # subclasses should implement
    def post_initialize
      # raise NotImplementedError
    end

    def get!
      execute!(:get)
    end

    def post!(body_type= :form_data)
      @body_type = body_type
      execute!(:post)
    end

    def execute!(type)
      @type = type.to_sym
      send_request
    end

    # @return [Self] Повторяет последний вызов метода
    # со всеми сохраненными параметрами и типом запроса
    def redo!
      send_request
    end

    def cookies
      cookies_array = @cookie_jar.to_a.join(';').split(';').map { |c| c.split('=') }

      # если кука приходит без значения - она сохраняется в массиве без пары, и to_h падает
      # докидываю в массив пустой элемент в этом случае
      cookies_array.each { |e| e[1] = '' if e.count == 1 }
      cookies_array.to_h
    end

    def uri
      uri              = Addressable::URI.parse(method)
      uri.query_values = @query
      uri
    end

    def url
      uri.to_s
    end

    def self.present_cookie_jar(jar)
      cookies_array       = jar.to_a
      curl_cookies_string = cookies_array.map(&:to_s).join('; ') + ';'
    end

    private

    def prepare_cookies
      @cookie_jar
    end

    def default_cookies
      #todo default cookies management
      # [HTTP::Cookie.new(name:   'ENVID',
      #                   value:  @config.environment,
      #                   domain: '.onetwotrip.com',
      #                   path:   '/'),
      #  HTTP::Cookie.new(name:   'ENVID',
      #                   value:  @config.environment,
      #                   domain: '.twiket.com',
      #                   path:   '/')]
      []
    end

    def prepare_headers
      default_headers.merge(@headers)
    end

    def default_headers
      # дефолтные значения заголовков
      # todo russian comments
      # todo content_type management
      # todo user_agent management
      { content_type: 'application/json; charset=utf-8',
        cookies:      prepare_cookies,
        user_agent:   'OTT-Ruby-Testing-Framework' }
    end

    def parse_json_response
      @response = JSON.parse(raw_response, symbolize_names: true)
    rescue JSON::ParserError
      nil
    end

    # noinspection RubocopInspection
    def with_logging
      log(url, ">> #{@type}-request")
      log(self.class.present_cookie_jar(@cookie_jar), '>> cookies-jar') unless @cookie_jar.cookies.empty?

      @request_time = Time.now.utc
      yield if block_given?
      @time_taken = time_from(@request_time, Time.now.utc)

      log(response_cookies_string, '<< cookies') unless raw_response.cookies.empty?
      log("#{@raw_response.code}. #{@time_taken} ms.", '<< response')
    end

    def send_request
      with_logging { http_sender }
      raise report_data if raw_response.code > 500
      parse_json_response
      #todo post_initialize documentation
      post_initialize # subclasses should implement
      self
    end

    def response_cookies_string
      self.class.present_cookie_jar(@raw_response.cookie_jar)
    end

    def request_cookies_string
      self.class.present_cookie_jar(@cookie_jar)
    end

    def http_sender(timeout=120)
      #todo default timeout management
      req_opts      = { method:   @type,
                        url:      uri.to_s,
                        payload:  prepare_body(@body, @body_type),
                        headers:  prepare_headers,
                        timeout:  timeout,
                        user:     authorisation[:login],
                        password: authorisation[:password] }
      @raw_response = RestClient::Request.execute(req_opts) { |response, _request, _result| response }.force_encoding('UTF-8')
      @raw_request  = @raw_response.request
    rescue RestClient::RequestTimeout => e # у RestClient классы исключений генерируются на лету, отсюда ошибка не видимости класса
      message = "#{e}. #{timeout} seconds."
      raise report_data(message)
    end

    # @param [Object] body as a hash, string
    # @param [Object] body_type
    def prepare_body(body, body_type)
      case body_type
        when :form_data
          body
        when :json
          JSON.unparse(body)
        else # as a string
          body.to_s
      end
    end
  end
end
