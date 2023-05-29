# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Namespace module
module KodiFavGen
end

# Main application
#
# Samples of use
# ```shell
# kodi-favgen directory='samples'
# kodi-favgen directory='samples' output='/dev/stdout'
# ```
class KodiFavGen::App
  autoload(:REXML, 'rexml')

  class << self
    # @api private
    MANDATORY_PARAMS = [:directory]

    def call(argv = nil)
      ::KodiFavGen::Config.call(argv || ARGV.dup).yield_self do |config|
        MANDATORY_PARAMS.each do |key|
          halt("#{key} must be set", status: 22) if config.get(key).nil?
        end

        ::KodiFavGen::Template.new.yield_self do |template|
          ::KodiFavGen::Output.new(template).call
        rescue REXML::ParseException => e
          halt(e.message, status: 125) # ECANCELED
        rescue ::StandardError => e
          if e.class.name&.match(/^Errno::/) and e.class.constants.include?(:Errno)
            # noinspection RubyMismatchedArgumentType
            halt(e.message, status: e.class::Errno)
          end

          raise(e)
        end
      end
    end

    protected

    # @param [String, nil] message
    # @param [Fixnum] status
    def halt(message, status: 1)
      if message&.is_a?(String) and message.to_s.strip != ''
        if status.to_i.zero?
          warn(message)
        else
          puts(message)
        end
      end

      exit(status.to_i)
    end
  end
end

# Describe configuration (from environment).
class KodiFavGen::Config
  BASE_NAME = 'KODI_FAV'

  # @param [Symbol]
  #
  # @return [String, nil]
  def get(name)
    ::ENV[key(name.to_s)]
  end

  class << self
    # @param [Array<String>] payload
    #
    # @return [KodiFavGen::Config]
    def call(payload)
      payload.map(&:to_s).map do |data|
        parts = data.split('=')
        [parts[0].to_s, parts[1..-1]&.join('=')].map(&:to_s).yield_self do |pair|
          self.set(*pair) unless pair.map(&:empty?).include?(true)
        end
      end.yield_self { self.new }
    end

    protected

    def set(key, value)
      self.key(key).yield_self do |env_key|
        ::ENV[env_key] = value unless value.to_s.empty?
      end
    end

    # @param [String] name
    #
    # @return [String, nil]
    def key(name)
      return nil if name.empty?

      [BASE_NAME, name.upcase].join('__')
    end
  end

  protected

  # @param [String] name
  #
  # @return [String]
  def key(name)
    self.class.__send__(:key, name)
  end
end

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

# Template (rendering).
class KodiFavGen::Template
  autoload(:ERB, 'erb')
  autoload(:REXML, 'rexml')

  TEMPLATE = %{<?xml version="1.0" encoding="<%= ''.encoding.to_s %>"?>
<favourites>
  <%- @favourites.each do |favourite| -%>
  <favourite id="<%= favourite.id %>"
             name="<%= favourite.name %>"
             thumb="<%= favourite.thumb %>"><%= favourite.action %>></favourite>
  <%- end -%>
</favourites><%= "\n" -%>}

  # @param [KodiFavGen::Glob] glob
  def initialize(glob = nil)
    (glob || ::KodiFavGen::Glob.new).tap do |v|
      @path = v.path
    end.call.yield_self do |v|
      @items = self.itemize(v)
    end
  end

  # Executes to produce a completed template, returning the results of that code.
  #
  # Result is parsed before returning, to ensure XML validity.
  #
  # @return [String]
  def call
    Object.new.tap do |context|
      context.instance_variable_set('@favourites', items)
    end.yield_self do |context|
      ERB.new(TEMPLATE, trim_mode: '->')
         .result(context.instance_eval { binding })
         .tap { |xml| self.parse(xml) }
    end
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [Array<Struct>]
  attr_reader :items

  def itemize(glob)
    glob.map do |item|
      {
        id: item.fetch('id'),
        name: item.fetch('name'),
        action: item.fetch('action').lines.map(&:chomp).join,
        thumb: lambda do
          item['thumb_b64']&.yield_self do |b64|
            return ::KodiFavGen::Thumb.new(b64.lines.map(&:chomp).join).call&.to_s
          end

          return nil unless item['thumb']

          Pathname.new(item.fetch('thumb')).yield_self do |thumb|
            (thumb.absolute? ? thumb : Pathname.new(path).join('thumbs').glob("#{thumb}.*").first).read.yield_self do |v|
              ::KodiFavGen::Thumb.new(v, base64: false).call.to_s
            end
          rescue StandardError => e
            warn("#{e.message} for #{item['id'].inspect}").yield_self { nil }
          end
        end.call
      }.yield_self { |v| Struct.new(*v.keys, keyword_init: true).new(v) }
    end
  end

  # Ensures given XML string is valid, raises error otherwise.
  #
  # @param [String] xml
  #
  # @return [REXML::Document]
  # @raise [REXML::ParseException]
  def parse(xml)
    REXML::Document.new(xml)
  end
end

# Image processing.
class KodiFavGen::Thumb
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Base64, 'base64')
  autoload(:Digest, 'digest')

  # @param [String] content as binary image file content or base64 encoded.
  def initialize(content, base64: true)
    @content = base64 ? Base64.decode64(content) : content

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

  def filename
    Digest::MD5.hexdigest(content)
  end

  def directory
    {
      progname: self.class.name.split('::').first,
      uid: self.uid,
    }.yield_self do |h|
      self.tmpdir.join('%<progname>s.%<uid>s' % h)
    end
  end

  # @return [Module<FileUtils>]
  def fs
    # noinspection RubyResolve
    FileUtils
  end

  def uid
    ::Process.euid
  end

  def tmpdir
    require('tmpdir').yield_self do
      ::Dir.tmpdir.yield_self { |v| Pathname.new(v).realpath }
    end
  end
end

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

KodiFavGen::App.call if __FILE__ == $0
