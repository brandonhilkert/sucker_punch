class CrashingJob
  include SuckerPunch::Job
  workers 4

  def perform
    raise 'Oooops, I just crashed'
  end
end

