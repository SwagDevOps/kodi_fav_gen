# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../errors')

# Error encountered during generation.
class KodiFavGen::Errors::GenerationError < ::StandardError
  # @param [String, nil] message
  # @param [Hash{Symbol => Array<Exception>}] history
  def initialize(message = nil, history: {})
    super(message || 'Errors were encountered during generation')
    @history = history.freeze
  end

  # @return [Hash{Symbol => Array<Exception>}]
  def history
    lambda do
      autoload(:JSON, 'json')

      JSON.pretty_generate(@history)
    end.then do |functor|
      @history.dup.tap do |h|
        h.singleton_class.__send__(:define_method, :to_json) { functor.call }
      end
    end
  end
end
