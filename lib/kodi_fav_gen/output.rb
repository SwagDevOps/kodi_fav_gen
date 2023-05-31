# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Image processing.
class KodiFavGen::Output
  autoload(:Pathname, 'pathname')

  DEFAULT_FILE = '.kodi/userdata/favourites.xml'

  # @param [KodiFavGen::Template] subject
  # @param [KodiFavGen::Config, nil] config
  def initialize(subject, config: nil)
    @subject = subject
    @config = config || ::KodiFavGen::Config.new
  end

  # Write to file.
  #
  # @return [Pathname]
  def call
    self.file.tap do |file|
      file.write(subject.call)
    end
  end

  protected

  # @return [KodiFavGen::Template]
  attr_reader :subject

  # @return [KodiFavGen::Config]
  attr_reader :config

  # Get file to write.
  #
  # @return [Pathname]
  def file
    (config.get('output') || "#{ENV.fetch('HOME')}/#{DEFAULT_FILE}")
      .yield_self { |fp| Pathname.new(fp) }
  end
end
