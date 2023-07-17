# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../template')

# Template (rendering) from a named file.
class KodiFavGen::Template::ErbFile < KodiFavGen::Template::File
  autoload(:Pathname, 'pathname')

  # @param [String] filename
  def initialize(filename)
    erb_path.join("#{filename}.erb").realpath.tap do |template|
      super(template)
    end
  end

  protected

  # @return [Pathname]
  def erb_path
    Pathname.new(::KodiFavGen::ERB_PATH).realpath
  end
end
