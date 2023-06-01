# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../template')

# Template (rendering) from a file.
#
# @abstract
# @api private
class KodiFavGen::Template::File < KodiFavGen::Template::String
  autoload(:Pathname, 'pathname')

  def initialize(filepath)
    Pathname.new(filepath).realpath.read.tap do |template|
      @file = template

      super(template)
    end
  end

  # @return [String]
  def to_path
    @file.to_path
  end
end
