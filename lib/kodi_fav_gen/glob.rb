# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Glob a directory to list YML files.
class KodiFavGen::Glob
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  # @return [Pathname]
  attr_reader :path

  # @param [String] path
  def initialize(path = nil)
    @path = Pathname.new(path || KodiFavGen::Config.new.get(:directory)).realpath.freeze

    freeze
  end

  # @return [Array<Hash{String => Object}>]
  def call
    self.path.glob('*.yml').sort.map do |file|
      YAML.safe_load(file.read).yield_self do |h|
        { 'id' => file.basename('.*').to_s }.merge(h)
      end
    end
  end
end
