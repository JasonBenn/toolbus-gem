require 'parser/current'

class SyntaxTree
  def initialize(ruby)
    # todo: turn on
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
    `git log --oneline $(git remote)/master...HEAD`.length == 0
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

  def at_width(width)
    truncate(width).ljust(width)
  end
end
