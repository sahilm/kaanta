module Kaanta
  class Worker
    attr_reader :number, :tempfile

    def initialize(master_pid, socket, tempfile, number,logger)
      @master_pid = master_pid
      @socket     = socket
      @tempfile   = tempfile
      @number     = number
      @logger     = logger
    end

    def ==(other_number)
      self.number == other_number
    end

    def start
      $PROGRAM_NAME = "kaanta worker #{number}"
      Kaanta::Master::SIGNALS.each { |sig| trap(sig, 'IGNORE') }
      trap('CHLD', 'DEFAULT')
      alive = true
      %w(TERM INT).each { |sig| trap(sig) { exit(0) } }
      trap('QUIT') do
        alive = false
        @socket.close rescue nil
      end
      i = 0
      logger.info("up")
      while alive && @master_pid == Process.ppid do
        tempfile.chmod(i += 1)

        begin
          client = @socket.accept_nonblock
          data = client.gets
          logger.info(data)
          client.close
        rescue Errno::EAGAIN
        end
        tempfile.chmod(i += 1)
        ret = IO.select([@socket], nil, nil, Config.timeout / 2) or next
      end
    end

    private
    attr_reader :logger
  end
end
