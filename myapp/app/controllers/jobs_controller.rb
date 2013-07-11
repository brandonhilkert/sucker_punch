class JobsController < ApplicationController
  def index
    @store = STORE
  end

  def single
    SingleJob.new.async.perform
    redirect_to jobs_path
  end

  def multiple
    MultipleJob.new.async.perform
    redirect_to jobs_path
  end
end
