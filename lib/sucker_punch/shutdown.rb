module SuckerPunch
  module Shutdown
    class Hard
      def shutdown(job, queue)
        queue.kill
        SuckerPunch.logger.info("Hard shutdown triggered for #{job}...byebye")
      end
    end

    class Soft
      def shutdown(job, queue)
        SuckerPunch.logger.info("Soft shutdown triggered for #{job}...executing remaining in-process jobs")
        queue.shutdown
        queue.wait_for_termination(10)
        SuckerPunch.logger.info("Terminating...byebye")
      end
    end

    class None
      def shutdown(job, queue)
        SuckerPunch.logger.info("Shutdown triggered for #{job}...excuting remaining in-process and queued jobs")
        queue.wait_for_termination
        SuckerPunch.logger.info("Terminating...byebye")
      end
    end

    SHUTDOWN_MODES = Hash.new(SuckerPunch::Shutdown::Soft).merge(
      hard: SuckerPunch::Shutdown::Hard,
      none: SuckerPunch::Shutdown::None,
    )

    def self.mode(mode)
      SHUTDOWN_MODES[mode]
    end
  end
end
