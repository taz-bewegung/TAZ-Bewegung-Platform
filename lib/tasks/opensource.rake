require "find"

namespace :opensource do
  desc "check for copyright licence"
  task :check_licence => :environment do
    require 'find'
    Find.find("app") do |f| 
      if f.match(/\.rb$/)
        
        if open(f).grep(/This file is part of bewegung/) == []
          p "#{f} has no licence!"
        end
      end
    end
  end
end