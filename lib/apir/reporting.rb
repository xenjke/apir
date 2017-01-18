module Apir
  # reporting module
  module RequestReporting
    # reporting class
    class RequestReport
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

    def report_data(message=nil)
      RequestReport.new(self, raw_response, message).print_report
    end

    # @return [String] request curl string
    def curl
      curl_string = "curl '#{url}' #{curl_make_headers} #{curl_make_body} -i"
      curl_string.gsub(/\s+/, ' ').strip
    end

    private

    def curl_make_headers
      headers_clone          = headers.clone
      headers_clone[:cookie] = Apir::Request.present_cookie_jar(cookie_jar)
      headers_clone.compact.map { |k, v| "-H '#{k}: #{v}'" }.join(' ')
    end

    def curl_make_body
      body_string = case body && body_type
                      when :form_data
                        URI.encode_www_form(body)
                      when :json
                        JSON.unparse(body)
                      else
                        body.to_s
                    end
      @body ? "--data '#{body_string}'" : ''
    end
  end
end
