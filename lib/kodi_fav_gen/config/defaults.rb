# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Defaults values for config parameters.
#
# ``nil`` values are ignored.
# ``proc`` are evaluated later.
#
# @see KodiFavGen::Config.call
# @see KodiFavGen::Config.prepare

{
  path: nil,
  # @type [Hash] config
  thumbs_path: lambda do |config|
    config.fetch(:path).then do |path|
      Pathname.new(path).join('..', 'thumbs') if path
    end
  end,
  output: proc do
    ::ENV.fetch('HOME') do
      Etc.getpwuid(::Process.uid).dir
      # @type [String] home_dir
    end.to_s.then do |home_dir|
      Pathname.new(home_dir).join('.kodi/userdata/favourites.xml')
    end
  end,
  tmpdir: proc do
    ::ENV.fetch('TMPDIR') do
      require('tmpdir').then { ::Dir.tmpdir }
      # @type [String] tmp_dir
    end.to_s.then do |tmp_dir|
      {
        name: (self.is_a?(Class) ? self : self.class).name.split('::').first,
        uid: ::Process.uid,
      }.then do |h|
        Pathname.new(tmp_dir).join('%<name>s.%<uid>s' % h)
      end
    end
  end,
  update_path: nil,
  update_branch: nil,
}.tap do
  autoload(:Etc, 'etc')
  autoload(:Pathname, 'pathname')
end
