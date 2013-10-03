require 'bundler/capistrano'
set :user, 'aaron.seibert'
set :applicationdir, "/var/nfs/www_files/#{domain}"
set :gateway, 'aaron.seibert@ewrpmgmt01.binaryitsystems.com'

set :scm, 'git'
set :repository,  "https://github.com/Lateral-October/hosting-panel.git"
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
  
# roles (servers)
role :nfs, "ewrpmgmt01.binaryitsystems.com"
role :web, "ewrpweb01a.binaryitsystems.com", "ewrpweb01b.binaryitsystems.com", :no_release => true
role :app, "ewrpweb01a.binaryitsystems.com", "ewrpweb01b.binaryitsystems.com", :no_release => true
role :db,  "ewrpmgmt01.binaryitsystems.com", :primary => true
   
# deploy config
set :deploy_to, applicationdir
set :deploy_via, :export
    
# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/home/user/.ssh/id_rsa)            # If you are using ssh_keysset :chmod755, "app config db lib public vendor script script/* public/disp*"set :use_sudo, false
     
# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
