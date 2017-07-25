# frozen_string_literal: true
require 'apir/report'

module Apir
  # reporting module
  module Reporting

    def report_data(message=nil, options = {})
      Apir::Report.new(self, raw_response, message).print_report(options)
    end

    # @return [String] request curl string
    def curl
      curl_string = "curl #{curl_make_type} #{curl_make_auth} '#{url}' #{curl_make_headers} #{curl_make_body} -i"
      curl_string.gsub(/\s+/, ' ').strip
    end

    private

    def curl_make_auth
      authorisation && authorisation.empty? ? '' : "-u #{authorisation[:login]}:#{authorisation[:password]}"
    end

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
        header_name  = k.to_s.split(/[_|-]/).each(&:capitalize!).join('-')
        header_value = v
        "-H '#{header_name}: #{header_value}'"
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
