task default: %w[ integration:sentinel:test ]

namespace :integration do

  base_dir = 'test/integration'

  namespace :sentinel do
    desc 'test sentinel'
    task :test do
      Dir.chdir("#{base_dir}/sentinel") do
        sh 'vagrant up'
        sh 'bundle exec rspec'
      end
    end

    desc 'cleanup sentinel'
    task :cleanup do
      Dir.chdir("#{base_dir}/sentinel") do
        sh 'vagrant destroy -f'
      end
    end
  end

end
