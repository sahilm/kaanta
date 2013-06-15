module Kaanta
  class Worker
    def initialize(master_pid, socket, wpipe, tempfile, worker_number,logger)
      @master_pid    = master_pid
      @socket        = socket
      @tempfile      = tempfile
      @wpipe         = wpipe
      @worker_number = worker_number
      @logger        = logger
    end

    def start
      $PROGRAM_NAME = "kaanta worker #{@worker_number}"
      Kaanta::Master::QUEUE_SIGS.each { |sig| trap(sig, 'IGNORE') }
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
        @tempfile.chmod(i += 1)

        begin
          client = @socket.accept_nonblock
          data = client.gets
          logger.info(data)
          client.close
        rescue Errno::EAGAIN
        end
        @tempfile.chmod(i += 1)
        ret = IO.select([@socket], nil, nil, Config.timeout / 2) or next
      end
    end

    private
    attr_reader :logger
  end
end
