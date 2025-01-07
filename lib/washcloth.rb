# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

require_relative "washcloth/version"

module Washcloth
  class Error < StandardError; end

  def self.reset
    Internal.reset
  end

  def self.filter(value, filter: filters.chars("*"))
    Internal.add_filter(value, filter)
  end

  def self.clean(value)
    Internal.configuration.filters.inject(value) do |memo, (_, filter)|
      Formatters::ActiveRecord.new(filter).run(
        Formatters::Xml.new(filter).run(memo)
      )
    end
  end

  def self.filters
    Filters
  end

  module Formatters
    class Xml
      def initialize(filter)
        @filter = filter
      end

      def regexp
        /<#{@filter.name}>(?<inner>.*)<\/#{@filter.name}>/mi
      end

      def run(value)
        value.gsub(regexp) do |match|
          last_match = Regexp.last_match[:inner]
          match.sub(last_match, @filter.filter[last_match])
        end
      end
    end

    class ActiveRecord
      def initialize(filter)
        @filter = filter
      end

      def regexp
        / #{@filter.name}: "(?<inner>.*)"/mi
      end

      def run(value)
        value.gsub(regexp) do |match|
          last_match = Regexp.last_match[:inner]
          match.sub(last_match, @filter.filter[last_match])
        end
      end
    end
  end

  module Internal
    class << self
      delegate :add_filter, to: :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def reset
        @configuration = nil
      end
    end
  end

  class Configuration
    attr_reader :filters

    def initialize
      @filters = {}
    end

    def add_filter(filter_name, filter)
      @filters[filter_name.to_sym] = Filter.new(name: filter_name.to_sym, filter:)
    end
  end

  class Filter
    attr_reader :name, :filter

    def initialize(name:, filter:)
      @name = name
      @filter = filter
    end
  end

  module Filters
    class << self
      def static(value)
        ReplaceWithStaticValue.new(value)
      end

      def chars(value)
        ReplaceEachCharacter.new(value)
      end

      def block(value)
        ReplaceWithBlockOutcome.new(value)
      end
    end

    class ReplaceEachCharacter
      def initialize(replacement)
        @replacement = replacement
      end

      def [](value)
        value.chars.map { @replacement }.join
      end
    end

    class ReplaceWithBlockOutcome
      def initialize(block)
        @block = block
      end

      def [](value)
        @block.call(value)
      end
    end

    class ReplaceWithStaticValue
      def initialize(value)
        @value = value
      end

      def [](_)
        @value
      end
    end
  end
end
