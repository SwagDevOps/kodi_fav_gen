# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Image processing.
class KodiFavGen::Thumb
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Base64, 'base64')
  autoload(:Digest, 'digest')

  # @param [String] content as binary image file content or base64 encoded.
  def initialize(content, base64: true, tmpdir: nil)
    @content = base64 ? Base64.decode64(content) : content
    @tmpdir = tmpdir || ::KodiFavGen::Tmpdir.new

    freeze
  end

  # @return [Pathname]
  def call
    self.directory.yield_self do |dir|
      fs.mkdir_p(dir.to_s) unless dir.directory?
      dir.join(filename).tap do |file|
        file.write(content) unless file.exist?
      end
    end
  end

  protected

  # @return [String]
  attr_reader :content

  # @return [KodiFavGen::Tmpdir]
  attr_reader :tmpdir

  # @return [String]
  def filename
    Digest::MD5.hexdigest(content)
  end

  # @return [Pathname]
  def directory
    tmpdir.configured? ? tmpdir.path : lambda do
      {
        progname: self.class.name.split('::').first,
        uid: self.uid,
      }.then { |h| self.tmpdir.join('%<progname>s.%<uid>s' % h) }
    end.call
  end

  # @return [Module<FileUtils>]
  def fs
    # noinspection RubyResolve
    FileUtils
  end

  # @return [Integer]
  def uid
    ::Process.euid
  end
end
