require 'rake/testtask'

Rake::TestTask.new :spec do |t|
  t.test_files = ['spec/viva_spec.rb']
end

task :default do
  IO.new(0).puts <<JOKE

rm: it is dangerous to operate recursively on '/'
rm: use --no-preserve-root to override this failsafe

JOKE
end
