# frozen_string_literal: true

module Apir
  # reporting class
  class Report
    def initialize(request, response, message=nil)
      @request  = request
      @response = response
      @message  = message
    end

    def print_report
      print = report.map do |k, v|
        "#{k.upcase}: '#{v}'" unless v.nil?
      end.compact.join("\r\n")
      "\r\n" + print
    end

    def report
      { time:          request_time,
        url:           url,
        curl:          @request.curl,
        headers:       headers,
        cookies_sent:  cookies_sent,
        request_body:  request_body,
        response_code: response_code,
        response_body: response_body,
        message:       @message }
    end

    private

    def url
      @request.url
    end

    def request_time
      @request.request_time
    end

    def headers
      JSON.unparse(@request.headers) unless @request.headers.empty?
    end

    def cookies_sent
      @request.cookies if @request && !@request.cookies.empty?
    end

    def request_body
      return nil unless @request && @request.body
      case @request.body_type
        when :form_data
          @request.body
        when :json
          JSON.unparse(@request.body) rescue @request.body
        else # as a string
          @request.body.to_s
      end
    end

    def response_code
      @response && @response.code
    end

    def response_body
      @response && @response.body
    end
  end
end
