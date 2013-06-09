module Kaanta

  module Config
    class << self
      attr_accessor :host, :port, :daemonize, :workers, :timeout
    end
  end
end
