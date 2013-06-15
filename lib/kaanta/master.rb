module Kaanta

  class Master
    SIGNALS = %w(QUIT INT TERM).map { |x| x.freeze }.freeze

    def initialize
      @rpipe, @wpipe  = IO.pipe
      @workers        = {}
      @sig_queue      = []
    end

    def start
      $PROGRAM_NAME = "kaanta master"
      @master_pid = Process.pid
      $stderr.sync = $stdout.sync = true
      setup_logging
      @socket = TCPServer.open(Config.host, Config.port)
      logger.info("Accepting connections on #{Config.host}: #{Config.port}")
      spawn_workers
      SIGNALS.each { |sig| trap_deferred(sig) }
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


    private

    def stop

    end

    def reap_workers
      loop do
        pid, status = Process.waitpid2(-1, Process::WNOHANG)
        break unless pid
        worker = @workers.delete(pid)
        worker.tempfile.close rescue nil
        logger.info "reaped worker #{worker.number} " \
                    "(PID:#{pid})"
      end
    rescue Errno::ECHILD
    end

    def kill_runaway_workers
    end

    def spawn_workers
      worker_number = -1
      until (worker_number += 1) == Config.workers
        @workers.value?(worker_number) && next
        tempfile = Tempfile.new('')
        tempfile.unlink
        tempfile.sync = true
        worker = Kaanta::Worker.new(@master_pid, @socket, tempfile, worker_number,logger)
        if pid = fork
          @workers[pid] = worker
        else
          @wpipe.close
          @rpipe.close
          worker.start
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
        "[#{$PROGRAM_NAME} (PID: #{Process.pid})] #{datetime}: #{severity} -- #{msg}\n"
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
