################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT net>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################

require 'bundler/gem_tasks'

################################################################################

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
task :test => :spec

################################################################################

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :coveralls => [:spec, 'coveralls:push']

################################################################################

require 'yard'
require 'yard/rake/yardoc_task'

GEM_NAME = File.basename(Dir.pwd)
DOC_PATH = File.expand_path(File.join("..", "/", "#{GEM_NAME}.doc"))

namespace :doc do
  YARD::Rake::YardocTask.new(:pages) do |t|

    # t.files = ['lib/**/*.rb']
    t.options = ['--verbose', '-o', DOC_PATH]
  end

  namespace :pages do

    desc 'Generate and publish YARD Documentation to GitHub pages'
    task :publish => ['doc:pages'] do
      describe = %x(git describe).chomp
      stats = %x(bundle exec yard stats).chomp

      commit_message = Array.new
      commit_message << "Generated YARD Documentation for #{GEM_NAME.upcase} #{describe}\n\n"
      commit_message << stats

      Dir.chdir(DOC_PATH) do
        puts(%x{git add -Av})
        puts(%x{git commit -m"#{commit_message.join}"})
        puts(%x{git push origin gh-pages})
      end
    end

  end

end
desc 'Alias to doc:yard'
task 'doc' => 'doc:yard'

################################################################################
