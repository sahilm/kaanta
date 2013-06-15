module Kaanta

  class Master
    def initialize
      @rpipe, @wpipe  = IO.pipe
      @workers        = {}
      @sig_queue      = []
    end

    def start
      $PROGRAM_NAME = "kaanta master"
      $stderr.sync = $stdout.sync = true
      setup_logging
      @socket = TCPServer.open(Config.host, Config.port)
      logger.info("Accepting connections on #{Config.host}: #{Config.port}")
      spawn_workers
      QUEUE_SIGS.each { |sig| trap_deferred(sig) }
      trap('CHLD') { @wpipe.write_nonblock(".") }

      loop do
        reap_workers
        case (mode = @sig_queue.shift)
        when nil
          kill_runaway_workers
          spawn_workers
        when 'QUIT'
          break
        when 'TERM', 'INT'
          break
        else
          logger.error "master process in unknown mode: #{mode}"
        end
        reap_workers
        ready = IO.select([@rpipe], nil, nil, 1) or next
        ready.first && ready.first.first or next
        @rpipe.read_nonblock(1)
      end
      stop
    end

    QUEUE_SIGS = %w(QUIT INT TERM HUP).map { |x| x.freeze }.freeze

    private

    def stop

    end

    def reap_workers
    end

    def kill_runaway_workers
    end

    def spawn_workers
      to_spawn = Config.workers - @workers.size
      return if to_spawn <= 0
      while @workers.size < to_spawn do
        tempfile = Tempfile.new('')
        tempfile.unlink
        tempfile.sync = true
        master_pid = Process.pid
        worker_number = @workers.size
        @workers[worker_number] = fork do
          Kaanta::Worker.new(master_pid, @socket, @wpipe,
                             tempfile, worker_number,logger).start
        end
      end
    end

    def trap_deferred(signal)
      trap(signal) do |_|
        @sig_queue << signal
        @wpipe.write_nonblock(".")
      end
    end

    def setup_logging
      logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{$PROGRAM_NAME} - #{Process.pid}] #{datetime}: #{severity} -- #{msg}\n"
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
