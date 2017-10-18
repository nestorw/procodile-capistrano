namespace :load do
  task :defaults do
    set :rvm_map_bins, fetch(:rvm_map_bins, []).push('procodile')
    set :bundle_bins, fetch(:bundle_bins, []).push('procodile')

    if binary = fetch(:procodile_binary, nil)
      SSHKit.config.command_map[:procodile] = binary
    end
    if user = fetch(:procodile_user, nil)
      SSHKit.config.command_map.prefix[:procodile].push("sudo -u #{user}")
    end
  end
end
namespace :procodile do
  within :current_path do

    desc 'Start procodile processes'
    task :start do
      on roles(fetch(:procodile_roles, [:app])) do
        execute :procodile, procodile_args(:start)
      end
    end

    desc 'Stop procodile processes'
    task :stop do
      on roles(fetch(:procodile_roles, [:app])) do
        execute :procodile, procodile_args(:stop)
      end
    end

    desc 'Restart procodile processes'
    task :restart do
      on roles(fetch(:procodile_roles, [:app])) do
        execute :procodile, procodile_args(:restart)
      end
    end

    after 'deploy:published', "procodile:restart"

    def procodile_args(command, options = "")
      if processes = fetch(:processes, nil)
        options = "-p #{processes} " + options
      end
      "#{command} -r #{current_path} #{options}"
    end
  end
end
