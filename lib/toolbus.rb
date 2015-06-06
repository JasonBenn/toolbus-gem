require 'pry'
require 'json/pure'
require 'open-uri'
require_relative './views.rb'

TOOLBUS_ROOT = File.join(`gem which toolbus`.chomp.chomp("/lib/toolbus.rb"))

require 'parser/current'
class SyntaxTree
  def initialize(ruby)
    # TODO: turn on, once you have a real implementation
    # @ast = Parser::CurrentRuby.parse(ruby)
  end

  def include?(smaller_ast)
    # TODO: find if smaller_ast is a subset of self.
    rand < 0.4 ? { first_line: 10, last_line: 12 } : nil
  end
end

module GitUtils
  attr_reader :repo_url, :head_sha

  def git_status_clean?
    `git status -s`.length == 0
  end

  def latest_commit_online?
    `git log --oneline origin/master..HEAD`.length == 0
  end

  def repo_url
    @repo_url ||= `git config --get remote.origin.url`.gsub('git@github.com:', '').chomp
  end

  def head_sha
    @head_sha ||= `git rev-parse HEAD`
  end
end

# Pulled from ActionSupport.
class String
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || '...'
    length_with_room_for_omission = truncate_at - omission.length
    stop = \
      if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{self[0, stop]}#{omission}"
  end
end

class Toolbus
  include GitUtils

  def initialize
    validate_repo
    @features = fetch_features
  end

  SCAN_TIME_SECONDS = 4.0
  def scan
    statuses = []
    progress = 0.0
    @features.map { |feature| feature.default = 0 } # helps measure progress
    num_steps = scanning_plan.inject(0) { |total, (file, blueprints)| total + blueprints.length }

    scanning_plan.each_with_index do |(file, search_for), file_index|
      statuses << "Scanning #{file}"
      search_for.each do |search_for|
        id = search_for.keys.first
        blueprint = search_for.values.first

        progress += 1
        begin
          match = SyntaxTree.new(file).include?(SyntaxTree.new(blueprint))
        rescue Parser::SyntaxError
          statuses << "Syntax Error: #{file}"
          next
        end

        if match
          feature = @features.find { |feature| feature['id'] == id }
          feature['count'] += 1
          statuses << "POST /completions: repo_url: #{repo_url}, feature_id: #{id}, commit: ???, filename: #{file}, first_line: #{match[:first_line]}, last_line: #{match[:last_line]}"
        end

        percent_complete = (progress / num_steps) * 100
        ConsoleManager.repaint([
          ProgressBarView.new(percent_complete),
          TableView.new(features_found),
          StatusBoxView.new(statuses),
          "Found #{num_completions} total completions across #{num_features_completed}/#{@features.count} features across #{file_index}/#{scanning_plan.count} files!"
        ])
        sleep SCAN_TIME_SECONDS / num_steps
      end
    end
  end

  private

  def fetch_features
    # TODO: GET all features for our tools and versions, once that API exists
    JSON.parse(File.read(File.open(File.join(TOOLBUS_ROOT, 'spec/fixture/sample.json'))))['data']
  end

  def validate_repo
    # ConsoleManager.error "Unpushed commits! Toolbus relies on Github to show code samples,
    # so your code should be online. Please push before running" unless git_status_clean?
    # ConsoleManager.error "Uncommitted changes! Toolbus tracks completions by commit SHA1, so please commit and push before running." unless latest_commit_online?
  end

  def scanning_plan
    hash_with_array_values = Hash.new { |h, k| h[k] = [] }

    @features.inject(hash_with_array_values) do |plan, feature|
      Dir.glob(feature['search_in']).each do |file|
        plan[file] << { feature['id'] => feature['search_for'] }
      end
      plan
    end
  end

  def feature_module_and_name(feature)
    [feature['module'], ': ', feature['name']].join
  end

  def features_found
    @features.map { |feature| [feature_module_and_name(feature), feature['count']] }.to_h
  end

  def num_completions
    @features.inject(0) { |total, feature| total + feature['count'] }
  end

  def num_features_completed
    @features.select { |feature| feature['count'] > 0 }.count
  end
end
