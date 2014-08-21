namespace :load do
  task :defaults do
    set :rainbows_pid, -> { File.join(current_path, "tmp", "pids", "rainbows.pid") }
    set :rainbows_config_path, -> { File.join(current_path, "config", "rainbows", "#{fetch(:rails_env)}.rb") }
    set :rainbows_roles, -> { :app }
    set :rainbows_options, -> { "" }
    set :rainbows_rack_env, -> { fetch(:rails_env) == "development" ? "development" : "deployment" }
    set :rainbows_restart_sleep_time, 3
  end
end

namespace :rainbows do
  desc "Start rainbows"
  task :start do
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        if test("[ -e #{fetch(:rainbows_pid)} ] && kill -0 #{pid}")
          info "rainbows is running..."
        else
          with rails_env: fetch(:rails_env) do
            execute :bundle, "exec rainbows", "-c", fetch(:rainbows_config_path), "-E", fetch(:rainbows_rack_env), "-D", fetch(:rainbows_options)
          end
        end
      end
    end
  end

  desc "Stop rainbows (QUIT)"
  task :stop do
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        if test("[ -e #{fetch(:rainbows_pid)} ]")
          if test("kill -0 #{pid}")
            info "stopping rainbows..."
            execute :kill, "-s QUIT", pid
          else
            info "cleaning up dead rainbows pid..."
            execute :rm, fetch(:rainbows_pid)
          end
        else
          info "rainbows is not running..."
        end
      end
    end
  end

  desc "Reload rainbows (HUP); use this when preload_app: false"
  task :reload do
    invoke "rainbows:start"
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        info "reloading..."
        execute :kill, "-s HUP", pid
      end
    end
  end

  desc "Restart rainbows (USR2); use this when preload_app: true"
  task :restart do
    invoke "rainbows:start"
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        info "rainbows restarting..."
        execute :kill, "-s USR2", pid
      end
    end
  end

  desc "Duplicate rainbows; alias of rainbows:restart"
  task :duplicate do
    invoke "rainbows:restart"
  end

  desc "Legacy Restart (USR2 + QUIT); use this when preload_app: true and oldbin pid needs cleanup"
  task :legacy_restart do
    invoke "rainbows:restart"
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        execute :sleep, fetch(:rainbows_restart_sleep_time)
        if test("[ -e #{fetch(:rainbows_pid)}.oldbin ]")
          execute :kill, "-s QUIT", pid_oldbin
        end
      end
    end
  end

  desc "Add a worker (TTIN)"
  task :add_worker do
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        info "adding worker"
        execute :kill, "-s TTIN", pid
      end
    end
  end

  desc "Remove a worker (TTOU)"
  task :remove_worker do
    on roles(fetch(:rainbows_roles)) do
      within current_path do
        info "removing worker"
        execute :kill, "-s TTOU", pid
      end
    end
  end
end

def pid
  "`cat #{fetch(:rainbows_pid)}`"
end

def pid_oldbin
  "`cat #{fetch(:rainbows_pid)}.oldbin`"
end
