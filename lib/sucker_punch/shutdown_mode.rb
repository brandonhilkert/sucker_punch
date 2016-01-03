module SuckerPunch
  module ShutdownMode
    class Hard
      def shutdown(queue)
        queue.shutdown_now
      end
    end

    class Soft
      def shutdown(queue)
        queue.shutdown_and_finish_busy
      end
    end

    class None
      def shutdown(queue)
        queue.shutdown_and_finish_busy_and_enqueued
      end
    end

    SHUTDOWN_MODES = Hash.new(SuckerPunch::ShutdownMode::Soft).merge(
      hard: SuckerPunch::ShutdownMode::Hard,
      none: SuckerPunch::ShutdownMode::None,
    )

    def self.mode(mode)
      SHUTDOWN_MODES[mode]
    end
  end
end
