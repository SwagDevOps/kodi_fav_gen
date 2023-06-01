# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../template')

# Template (rendering) from a string.
#
# @abstract
# @api private
class KodiFavGen::Template::String
  autoload(:ERB, 'erb')

  # @param [String] template
  def initialize(template)
    @template = template.freeze

    freeze
  end

  def to_s
    template
  end

  # @return [String]
  def call(variables = {})
    Object.new.tap do |context|
      variables.each do |k, v|
        context.instance_variable_set("@#{k}", v)
      end
    end.then do |context|
      ERB.new(self.to_s, trim_mode: '->')
         .result(context.instance_eval { binding })
    end
  end

  protected

  # @return [String]
  attr_reader :template
end
