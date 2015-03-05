class JobGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_job_file
    template 'job.rb', File.join('app/jobs', class_path, "#{file_name}_job.rb")
  end
end
