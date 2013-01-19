module SuckerPunch
  class Error < StandardError; end
  class MissingQueueName < Error; end
  class MissingWorkerName < Error; end

end