class <%= class_name %>Job 
  include SuckerPunch::Job
  
  def perform
    raise NotImplementedError
  end
end
