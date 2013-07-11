class MultipleJob
  include SuckerPunch::Job
  workers 4

  def perform
    5.times do
      STORE << Time.now
      sleep 1
    end
  end
end

