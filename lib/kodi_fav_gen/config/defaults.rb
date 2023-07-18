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
  path: nil, # MUST BE SET
  thumbs_path: lambda do |config|
    config.fetch(:path).then do |path|
      Pathname.new(path).join('..', 'thumbs') if path
    end
  end,
  output: lambda do |_|
    ENV.fetch('HOME', Etc.getpwnam(Etc.getlogin).dir)
       .then { |home| Pathname.new(home) }
       .then { |home| home.join('.kodi/userdata/favourites.xml') }
  end,
  tmpdir: proc do
    begin
      ::ENV['TMPDIR'] || lambda do
        require('tmpdir').then { ::Dir.tmpdir }
      end.call
    end.then { |tmpdir| Pathname.new(tmpdir) }.then do |tmpdir|
      {
        name: (self.is_a?(Class) ? self : self.class).name.split('::').first,
        euid: ::Process.euid,
      }.then do |h|
        tmpdir.join('%<name>s.%<euid>s' % h)
      end
    end
  end
}.tap do
  autoload(:Etc, 'etc')
  autoload(:Pathname, 'pathname')
end
