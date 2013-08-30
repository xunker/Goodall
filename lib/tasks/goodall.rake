def goodall_installed?
  begin
    gem 'goodall'
  rescue Gem::LoadError
    false
  end
end

def running_under_rails?
  defined?(Rails)
end

def goodall_not_installed
  raise "the Goodall gem is not installed or not enabled. `bundle exec` may fix this."
end

def goodall_output_path
  if running_under_rails?
    "#{Rails.root}/doc/api_docs.txt"
  else
    Goodall.output_path
  end
end

def set_goodall_putput_path
  ENV['GOODALL_OUTPUT_PATH'] = goodall_output_path
end

def enable_goodall
  ENV['ENABLE_GOODALL'] = 'true'
end

namespace :cucumber do
  desc "Run cucumber and write Goodall documentation"
  goodall_not_installed unless goodall_installed?
  task :document => :environment do
    set_goodall_putput_path
    enable_goodall 
    Rake::Task["cucumber"].invoke
  end
end

namespace :spec do
  desc "Run rspec tests and write Goodall documentation"
  goodall_not_installed unless goodall_installed?
  task :document => :environment do
    set_goodall_putput_path
    enable_goodall 
    Rake::Task["spec"].invoke
  end
end

namespace :goodall do
  desc "Show current Goodall documentation output path"
  goodall_not_installed unless goodall_installed?
  task :output_path => :environment do
    puts "Goodall output path: #{goodall_output_path}"
  end
end

