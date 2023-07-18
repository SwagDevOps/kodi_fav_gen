# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../actions')

# Describe a base action.
#
# @abstract
class KodiFavGen::App::Actions::Base
  include(::KodiFavGen::Concerns::Halt)

  # @param [Array<String>, nil] argv
  # @param [Hash{String, Symbol => String}] defaults
  def initialize(argv = nil, defaults = {})
    self.argv(argv).then do |args|
      @config = ::KodiFavGen::Config.call(args, defaults.to_h.dup)
    end
  end

  def call
    mandatory_params
      .each { |key| config.get(key, exception: true) }
      .then { self.execute }
  end

  protected

  # @return [KodiFavGen::Config]
  attr_reader :config

  # Mandatory parameters.
  #
  # @abstract
  # @return [Array<Symbol>]
  def mandatory_params
    []
  end

  # Main process
  #
  # @abstract
  def execute
  end

  private

  # @param [Array<String>, nil] argv
  #
  # @return [Array<String>]
  def argv(argv = nil)
    (argv || ARGV).dup[1..-1].to_a
  end

  # Exit with given message.
  #
  # Outputs message to stdout on success or stderr on failure.
  #
  # @param [String, nil] message
  # @param [Fixnum] status
  def halt(message, status: 1)
    if message&.is_a?(String) and message.to_s.strip != ''
      if status.to_i.zero?
        puts(message)
      else
        warn(message)
      end
    end

    exit(status.to_i)
  end
end
