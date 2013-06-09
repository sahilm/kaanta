module Kaanta
  class Worker
    def initialize(master_pid, socket, wpipe, tempfile, logger)
      @master_pid = master_pid
      @socket     = socket
      @tempfile   = tempfile
      @wpipe      = wpipe
      @logger     = logger
    end

    def start
      Kaanta::Master::QUEUE_SIGS.each { |sig| trap(sig, 'IGNORE') }
      trap('CHLD', 'DEFAULT')
      $PROGRAM_NAME = "kaanta worker"
      alive = true
      %w(TERM INT).each { |sig| trap(sig) { exit(0) } }
      trap('QUIT') do
        alive = false
        @socket.close rescue nil
      end
      nr = 0
      while alive && @master_pid == Process.ppid do
        @tempfile.chmod(nr += 1)

        begin
          client = @socket.accept_nonblock
          data = client.gets
          @logger.info("data: #{data}")
          client.close
        rescue Errno::EAGAIN
        end
        @tempfile.chmod(nr += 1)
        ret = IO.select([@socket], nil, nil, Config.timeout / 2) or next
      end
    end
  end
end
