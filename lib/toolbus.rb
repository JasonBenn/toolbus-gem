require 'pry'
require 'json/pure'
require 'open-uri'

SCREEN_WIDTH = [`tput cols`.to_i, 100].min
def save_cursor; `tput sc`; end
def restore_cursor; `tput rc`; end
def erase_display; `tput clear`; end
def red; `tput setaf 1`; end
def green; `tput setaf 2`; end
def reset; `tput sgr0`; end

require_relative './view.rb'

def print_line(message, color)
  puts [color, message, reset].join
end

TOOLBUS_ROOT = File.join(`gem which toolbus`.chomp.chomp("/lib/toolbus.rb"))

# api_response = JSON.parse(File.read(File.open('./spec/fixture/sample.json')))
# times_encountered = api_response['data'].map { |feature| ["[#{feature['module']}]: #{feature['name']}", 0] }.to_h

# progress = ProgressBar.new(times_encountered.length)
# until true || progress.done? do
#   puts progress
#   # debug_counter = 0
#   times_encountered.each do |(key, value)|
#     # debug_counter += 1
#     # puts debug_counter
#     progress.increment
#     times_encountered[key] += 1 if rand(100) < 40
#     color = value > 0 ? green : red
#     done = value > 0 ? "✓" : " "
#     count = value.to_s
#     message = done + ' ' + key.ljust(SCREEN_WIDTH - 3) + count
#     print_line message, color
#   end

#   num_requirements = times_encountered.inject(0) { |accum, (k, v)| accum + v }
#   num_features = times_encountered.select { |k, v| v > 0 }.length
#   puts "Found #{num_requirements} requirements in #{num_features} features!"
#   sleep 0.4
# end

def git_status_clean?
  `git status -s`.length == 0
end

def latest_commit_online?
  `git log --oneline origin/master..HEAD`.length == 0
end

def println(color, message)
  print color
  puts message
  print RESET
end

class Toolbus

  def initialize
    validate_repo
    @features = fetch_features
  end

  def fetch_features
    # TODO: GET all features for our tools and versions, once that API exists
    JSON.parse(File.read(File.open(File.join(TOOLBUS_ROOT, 'spec/fixture/sample.json'))))['data']
  end

  def validate_repo
    View::Errors.uncommitted_changes unless git_status_clean?
    View::Errors.unpushed_commits unless latest_commit_online?
  end

  GRAMMARS_DIR = File.join(TOOLBUS_ROOT, 'lib')
  def update_grammars
    existing_grammars = Dir.glob(File.join(GRAMMARS_DIR, '/grammars/**/*')).select { |file| File.file? file }

    needed_grammars = @features.reject do |feature|
      latest_grammar = File.join(GRAMMARS_DIR, URI.parse(feature['grammar_url']).path)
      existing_grammars.include? latest_grammar
    end

    needed_grammars.each do |feature|
      grammar_url = feature['grammar_url']
      path = URI.parse(grammar_url).path
      grammar_dir = File.join(GRAMMARS_DIR, File.dirname(path))

      FileUtils.mkdir_p grammar_dir unless Dir.exists? grammar_dir

      View.update_status "Creating #{File.join(GRAMMARS_DIR, path)}"

      # TODO: when files actually exist at those URLs.
      # open(File.join(GRAMMARS_DIR, path), 'w') do |file|
        # file << open(grammar_url).read
      # end
    end
  end

  def scan
    # binding.pry
    # TRANSLATE globs to mapping of full_path => array of grammars
    # SCANNING AND PUSHING PHASE
    # EACH file with tasks
      # EACH feature
        # IF feature found?
          # add feature completion to POST request
          # update progress values!
        # increment progress bar
        # refresh view
      # POST new feature completions.
  end
end

toolbus = Toolbus.new
toolbus.update_grammars
toolbus.scan
