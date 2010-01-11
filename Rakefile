require 'rake'
require 'rake/testtask'

task :default  => :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/vapor/**/*_test.rb']
  t.warning = false
  t.verbose = false
end
