rubocop_dev_branch = "blueprint-free-develop"

desc "Run rubocop on all files"
task :rubocop do
  sh "bundle exec rubocop"
end

namespace :rubocop do
  desc "Run rubocop on all files and auto-fix"
  task :fix do
    sh "bundle exec rubocop -a"
  end
end

namespace :rubocop do
  desc "Run rubocop on modified files"
  task :changed do
    current_branch = ENV["CI_COMMIT_REF_NAME"] || `git name-rev --name-only HEAD`.strip.gsub(%r{remotes/origin/}, "")
    if current_branch == rubocop_dev_branch
      puts "Skipping rubocop on default branch"
    else
      branch = `git merge-base --fork-point #{rubocop_dev_branch}`.strip
      sh "git diff-tree -r --no-commit-id --name-only HEAD #{branch} | xargs bundle exec rubocop --force-exclusion"
    end
  end

  namespace :changed do
    desc "Run rubocop on modified files and auto-fix"
    task :fix do
      current_branch = ENV["CI_COMMIT_REF_NAME"] || `git name-rev --name-only HEAD`.strip.gsub(%r{remotes/origin/}, "")
      if current_branch == rubocop_dev_branch
        puts "Skipping rubocop on default branch"
      else
        branch = `git merge-base --fork-point #{rubocop_dev_branch}`.strip
        sh "git diff-tree -r --no-commit-id --name-only HEAD #{branch} | xargs bundle exec rubocop -a --force-exclusion"
      end
    end
  end
end
