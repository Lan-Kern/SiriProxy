require 'eventmachine'
require 'zlib'
require 'pp'

class String
  def to_hex(seperator=" ")
    bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
  end
end

class SiriProxy

  def initialize()
    # @todo shouldnt need this, make centralize logging instead
    $LOG_LEVEL = $APP_CONFIG.log_level.to_i
    EventMachine.run do
      begin
        puts "Starting SiriProxy on #{$APP_CONFIG.listen}:#{$APP_CONFIG.port}.."
        EventMachine::start_server($APP_CONFIG.listen, $APP_CONFIG.port, SiriProxy::Connection::Iphone) { |conn|
          $stderr.puts "start conn #{conn.inspect}"
          conn.plugin_manager = SiriProxy::PluginManager.new()
          conn.plugin_manager.iphone_conn = conn
        }
        puts "SiriProxy up and running."
      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{$APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end
