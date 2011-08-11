
namespace :rspec_migration do
  
  task :models => :environment do
    model_dirs = %w(app/models)
    model_dirs.each do |dir|
      
      Dir.foreach(dir) do |file|
        if file.match(/.rb$/)
          name = file.match(/(.*)\.rb/)[1].classify
          system "rails g model #{name} -s --skip-migration"
        end
      end
    
    end
  end
  
end