# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Simple wrapper built on top of git executable.
class KodiFavGen::Git
  # @param [KodiFavGen::Config, nil] config
  def initialize(config: nil)
    @quiet = (config || ::KodiFavGen::Config.new).get(:vcs_quiet) { _1 == true }

    self.freeze
  end

  class << self
    protected

    # @return [Hash{String => String}]
    def env
      {
        LANGUAGE: "en_US.#{''.encoding}",
        GIT_CONFIG_NOSYSTEM: 1,
        GIT_CONFIG: ::File::NULL,
        GIT_TERMINAL_PROMPT: 0,
      }.map do
        [_1.to_s, _2.to_s].map(&:freeze)
      end.to_h
    end
  end

  # Call a command.
  #
  # Sample of use:
  #
  # ```
  # git.call('clone', repo_url, path, '--quiet', exception: true)
  # git.call('clean', '--force')
  # git.call('pull', '--quiet')
  # ```
  def call(*args, **opts)
    opts = optionize(opts, exception: true)

    system(env, *['git'].concat(args), exception: opts.fetch(:exception))
  end

  # Force update (with clean) on current path.
  #
  # Sample of use:
  #
  # ```
  # Dir.chdir(vcs_path) do
  #   git.update(branch: 'master', quiet: true, exception: true)
  # end
  # ```
  #
  # @return [Boolean]
  def update(branch: 'main', **opts)
    opts = optionize(opts, exception: false, quiet: quiet?)

    true.tap do
      # noinspection RubyRedundantSafeNavigation
      [
        %w[clean --force],
        %w[pull --rebase --force],
        %w[gc --auto],
        ['checkout', branch&.to_s],
      ].map do |args|
        args.concat([opts[:quiet] == true ? '--quiet' : nil].compact)
      end.each do |args|
        self.call(*args, **opts).tap { return false unless _1 }
      end
    end
  end

  # Denote git is set in quiet mode (from config).
  #
  # @return [Boolean]
  def quiet?
    self.quiet
  end

  protected

  # @return [Boolean]
  attr_reader :quiet

  # @param [Hash{Symbol => Object}] opts
  #
  # @return [Hash{Symbol => Object}]
  def optionize(opts, **defaults)
    opts.tap do
      defaults.each { |k, v| opts[k] = v unless opts.key?(k) }
    end
  end

  # Environment used to execute commands.
  #
  # @return [Hash{String => String}]
  def env
    self.class.__send__(:env).then do |env|
      ::ENV.to_h.merge(env).freeze
    end
  end
end
