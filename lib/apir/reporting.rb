# frozen_string_literal: true
require 'apir/report'

module Apir
  # reporting module
  module Reporting

    def report_data(message=nil)
      Apir::Report.new(self, raw_response, message).print_report
    end

    # @return [String] request curl string
    def curl
      curl_string = "curl #{curl_make_type} '#{url}' #{curl_make_headers} #{curl_make_body} -i"
      curl_string.gsub(/\s+/, ' ').strip
    end

    private

    def curl_make_type
      @type ? "-X #{@type.upcase}" : ''
    end

    def curl_make_headers
      headers_clone           = headers.clone
      # hack for make RestClient cookieS in hash
      # to compete with standards cookiE
      headers_clone[:cookies] = nil
      headers_clone[:cookie]  = Apir::Request.present_cookie_jar(cookie_jar)
      headers_clone.compact.map do |k, v|
        "-H '#{k}: #{v}'"
      end.join(' ')
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
