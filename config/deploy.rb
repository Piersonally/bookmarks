set :application, "bookmarks"
set :local_repository, 'ssh://sampierson.net/Users/sam/Development/bookmarks.git'
set :repository,  "file:///Users/sam/Development/bookmarks.git"
set :scm, :git

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/Library/WebServer/sams-sites/bookmarks.sampierson.net"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "sampierson.net"
role :web, "sampierson.net"
role :db,  "sampierson.net", :primary => true

set :use_sudo, false

task :after_update_code do
  run "ln -s #{shared_path}/db/production.sqlite3 #{release_path}/db/"
  run "ln -s #{shared_path}/images/0000 #{release_path}/public/images/"
end
