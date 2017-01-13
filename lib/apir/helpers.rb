require 'colorize'

# todo disable default logging at all
# Timestamp of current time
#
# @return [String]
def timestamp
  Time.now.strftime('%H:%M:%S.%3N')
end

# Log something into console
# Can be disabled by ENV['disable_log']
#
# @param [String] string output this to console
# @param [Object] type classifying the message
# @return [String]
def log(string, log_type=nil)
  type = log_type || if self.class.name == 'Object'
                       'info'
                     else
                       self.class.name
                     end

  enabled    = ENV['disable_log'] ? false : true
  msg_string = string.to_s

  if enabled
    is_enabled  = [type] # всё включено, по умолчанию
    is_disabled = %w{debug} # выключены debug логи

    #colorise type
    type_string = case type
                    when 'error'
                      type.colorize(:red)
                    when 'request'
                      type.colorize(:cyan)
                    when 'PurchaseHelper'
                      type.colorize(:blue)
                    when /warning/i
                      type.colorize(:orange)
                    when /<<|>>|\++/
                      type.colorize(:yellow)
                    else
                      type.colorize(:green)
                  end

    string = %{#{timestamp.to_s.colorize(:white)} #{type_string}: #{msg_string}}
    puts string if is_enabled.include?(type) && !is_disabled.include?(type)
  end

end

# Get difference between two dates
#
# @param [Date] time_from
# @param [Date] time_to
# @return [Float] difference between from-to
def time_from(time_from='', time_to='')
  dif = time_to - time_from
  (dif * 1000).round
end