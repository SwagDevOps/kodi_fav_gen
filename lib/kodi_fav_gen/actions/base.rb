# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../actions')

# Describe a base action.
#
# This action does nothing.
class KodiFavGen::Actions::Base
  # @param [String] value
  def initialize(value, options = {})
    self.tap do
      @value = value.to_s.lines.map(&:chomp).join.freeze
      @options = (options || {}).transform_keys(&:to_sym).freeze
    end.freeze
  end

  def to_s
    self.value
  end

  protected

  # @return [String]
  attr_reader :value

  # @return [Hash{Symbol => Object}]
  attr_reader :options
end
