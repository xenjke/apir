# frozen_string_literal: true
require 'addressable/uri'
require 'http-cookie'
require 'rest-client'
require 'json'
require 'date'

require 'apir/reporting'

module Apir
  DEFAULT_TIMEOUT = 120
  # request class callable as #new
  # or could be used as class extension
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
    # hook to be called when the request is completed
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

    # executing self one more time
    def redo!
      send_request
    end

    def cookies
      cookies_array = @cookie_jar.to_a.join(';').split(';').map { |c| c.split('=') }
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

    # presenting HTTP::CookieJar as a curl'y -H string
    def self.present_cookie_jar(jar)
      cookies_array       = jar.to_a
      curl_cookies_string = cookies_array.map(&:to_s).join('; ')
      curl_cookies_string << ';' if cookies_array.size == 1
      curl_cookies_string
    end

    private

    def prepare_cookies
      @cookie_jar
    end

    def prepare_headers
      default_headers.merge(@headers)
    end

    def default_headers
      # TODO: content_type example
      # TODO: user_agent example
      { content_type: 'application/json; charset=utf-8',
        cookies:      prepare_cookies,
        user_agent:   'APIR-Ruby-Testing-Framework' }
    end

    def parse_json_response
      @response = JSON.parse(raw_response, symbolize_names: true)
    rescue JSON::ParserError
      nil
    end

    # may be overridden to present logging with instance variables
    # i.e.
    #
    # def with_logging #<-- overridden one
    #   log(url, ">> #{@type}-request")
    #   log(self.class.present_cookie_jar(@cookie_jar), '>> cookies-jar') unless @cookie_jar.cookies.empty?
    #   yield if block_given?
    #   log(response_cookies_string, '<< cookies') unless raw_response.cookies.empty?
    #   log("#{@raw_response.code}. #{@time_taken} ms.", '<< response')
    # end
    #
    #
    def with_logging
      yield if block_given?
    end

    def send_request
      with_logging { http_sender }
      raise report_data if raw_response.code > 500
      parse_json_response
      post_initialize
      self
    end

    def response_cookies_string
      self.class.present_cookie_jar(@raw_response.cookie_jar)
    end

    def request_cookies_string
      self.class.present_cookie_jar(@cookie_jar)
    end

    def http_sender(timeout=120)
      @request_time = Time.now.utc
      req_opts      = { method:   @type,
                        url:      uri.to_s,
                        payload:  prepare_body(@body, @body_type),
                        headers:  prepare_headers,
                        timeout:  timeout || Apir::DEFAULT_TIMEOUT,
                        user:     authorisation[:login],
                        password: authorisation[:password] }
      @raw_response = RestClient::Request.execute(req_opts) { |response, _request, _result| response }.force_encoding('UTF-8')
      @raw_request  = @raw_response.request
      @time_taken   = time_from(@request_time, Time.now.utc)
    rescue RestClient::RequestTimeout => e
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
