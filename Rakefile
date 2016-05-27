require 'tempfile'
require 'pathname'

role_dir = Pathname.new(__FILE__).dirname
role_name = Pathname.new(role_dir).basename

task default: %w[ integration:sentinel:test ]

namespace :integration do

  base_dir = 'test/integration'

  namespace :sentinel do
    desc 'test sentinel'
    task :test => [ :prepare ] do
      Dir.chdir("#{base_dir}/sentinel") do
        sh 'vagrant up'
        sh 'bundle exec rspec'
      end
    end

    desc 'prepare the test environment'
    task :prepare do
      ignore_files = %w[ vendor .kitchen .git test spec ].map { |f| "#{role_name}/#{f}" }
      tmpfile = Tempfile.new('.tarignore')
      tmpfile.write ignore_files.join("\n")
      tmpfile.close
      sh "tar -c -X #{tmpfile.path} -C ../ -f - #{role_name} | tar -x -C #{base_dir}/sentinel/roles -f -"
    end

    desc 'cleanup sentinel'
    task :cleanup do
      Dir.chdir("#{base_dir}/sentinel") do
        sh 'vagrant destroy -f'
      end
      sh "rm -rf #{base_dir}/sentinel/roles/*"
    end
  end

end
