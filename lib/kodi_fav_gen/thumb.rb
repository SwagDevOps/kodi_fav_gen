# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Image processing.
#
# Create a new file from given contents (as filepath or base64 contents).
class KodiFavGen::Thumb
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Base64, 'base64')
  autoload(:Digest, 'digest')

  # @param [String] content as binary image file content or base64 encoded.
  def initialize(content, base64: true, config: nil)
    @content = base64 ? Base64.decode64(content) : content
    @config = config || ::KodiFavGen::Config.new

    freeze
  end

  # Create a new file.
  #
  # @return [Pathname]
  def call
    self.cache_path.then do |dir|
      fs.mkdir_p(dir.to_s) unless dir.directory?
      dir.join(filename).tap do |file|
        file.write(content) unless file.exist?
      end
    end
  end

  protected

  # @return [String]
  attr_reader :content

  # @return [KodiFavGen::Config]
  attr_reader :config

  # @return [String]
  def filename
    Digest::MD5.hexdigest(content)
  end

  # @return [Pathname]
  def cache_path
    config.get(:tmpdir, exception: true) { Pathname.new(_1) }
  end

  # @return [Module<FileUtils>]
  def fs
    # noinspection RubyResolve
    FileUtils
  end
end
