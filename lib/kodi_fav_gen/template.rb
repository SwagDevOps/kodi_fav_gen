# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

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
