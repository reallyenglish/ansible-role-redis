node ('virtualbox') {
  def directory = "ansible-role-redis"
  env.ANSIBLE_VAULT_PASSWORD_FILE = "~/.ansible_vault_key"
  stage 'Clean up'
  deleteDir()

  stage 'Checkout'
  sh "mkdir $directory"
  dir("$directory") {
    checkout scm
  }
  dir("$directory") {
    stage 'bundle'
    sh 'bundle install --path vendor/bundle'

    stage 'bundle exec kitchen test'
    try {
      sh 'bundle exec kitchen test'
    } finally {
      sh 'bundle exec kitchen destroy'
    }

    stage 'integration'
    try {
      # use native rake instead of bundle exec rake
      # https://github.com/docker-library/ruby/issues/73
      sh 'rake integration:sentinel:test'
    } finally {
      sh 'rake integration:sentinel:cleanup'
    }
    stage 'Notify'
    step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
  }
}
