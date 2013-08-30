require 'goodall'
require 'rails'
module Goodall
  class Railtie < Rails::Railtie
    railtie_name :goodall

    rake_tasks do
      load "tasks/goodall.rake"
    end
  end
end