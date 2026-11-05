require 'voxpupuli/test/rake'

# test-kitchen needs the docker CLI already when the tasks are defined
if system('docker version', out: File::NULL, err: File::NULL)
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
end
