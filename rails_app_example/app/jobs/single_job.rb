class SingleJob
  include SuckerPunch::Job
  workers 4

  def perform
    STORE << Time.now
  end
end

