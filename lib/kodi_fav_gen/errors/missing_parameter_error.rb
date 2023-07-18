# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../errors')

# Occurs when a mandatory parameter is missing.
#
# @see [KodiFavGen::Config]
class KodiFavGen::Errors::MissingParameterError < ::StandardError
  # Parameter key.
  #
  # @return [String, Symbol, nil]
  attr_reader :key

  protected

  # @type [String, Symbol, nil]
  attr_writer :key

  class << self
    # @param [String, Symbol] key
    #
    # @return [KodiFavGen::Errors::MissingParameterError]
    def from_key(key)
      self.new("Missing parameter: #{key.to_s.inspect}").tap do |error|
        error.__send__(:key=, key)
      end
    end
  end
end
