module SuckerPunch
  module Generators
    class JobGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc <<desc
description:
    create job in app/jobs directory
desc

      def create_job_file
        template 'job.rb', File.join('app/jobs', class_path, "#{file_name}_job.rb")
      end
    end
  end
end
