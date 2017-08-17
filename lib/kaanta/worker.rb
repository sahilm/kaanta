# frozen_string_literal: true

module Kaanta
  class Worker
    attr_reader :number, :tempfile

    def initialize(master_pid, socket, tempfile, number, logger)
      @master_pid = master_pid
      @socket     = socket
      @tempfile   = tempfile
      @number     = number
      @logger     = logger
    end

    def ==(other_number)
      number == other_number
    end

    def start
      $PROGRAM_NAME = "kaanta worker #{number}"
      Kaanta::Master::SIGNALS.each { |sig| trap(sig, 'IGNORE') }
      trap('CHLD', 'DEFAULT')
      alive = true
      %w[TERM INT].each { |sig| trap(sig) { exit(0) } }
      trap('QUIT') do
        alive = false
        begin
          @socket.close
        rescue
          nil
        end
      end
      ret = nil
      i = 0
      logger.info('up')
      while alive && @master_pid == Process.ppid
        tempfile.chmod(i += 1)

        if ret
          begin
            client = @socket.accept_nonblock
            command = client.gets
            logger.info("Executing: #{command}")
            client.write `#{command}`
            client.flush
            client.close
          rescue Errno::EAGAIN
          end
        end
        tempfile.chmod(i += 1)
        ret = begin
            IO.select([@socket], nil, nil, Config.timeout / 2) || next
          rescue Errno::EBADF
          end
      end
    end

    private

    attr_reader :logger
  end
end
