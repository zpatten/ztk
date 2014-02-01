require 'yard'
require 'yard/rake/yardoc_task'

GEM_NAME    = File.basename(Dir.pwd)
VENDOR_PATH = File.expand_path(File.join(Dir.pwd, "vendor"))
DOC_PATH    = File.join(VENDOR_PATH, "docs")

namespace :doc do

  YARD::Rake::YardocTask.new(:pages) do |t|
    if !File.exists?(DOC_PATH)
      remote = %x(git remote -v | grep 'origin').split[1].strip

      FileUtils.mkdir_p(VENDOR_PATH)
      Dir.chdir(VENDOR_PATH) do
        system(%(git clone --branch gh-pages #{remote} #{DOC_PATH}))
      end
    end

    t.options = ['--verbose', '-o', DOC_PATH]
  end

  namespace :pages do

    desc 'Generate and publish YARD Documentation to GitHub pages'
    task :publish => ['doc:pages'] do
      describe = %x(git describe).chomp
      stats    = %x(bundle exec yard stats).chomp

      commit_message = Array.new
      commit_message << "Generated YARD Documentation for #{GEM_NAME.upcase.inspect} #{describe}\n\n"
      commit_message << stats

      Dir.chdir(DOC_PATH) do
        system(%(git add -Av))
        system(%(git commit -m"#{commit_message.join}"))
        system(%(git push origin gh-pages))
      end
    end

  end

end
