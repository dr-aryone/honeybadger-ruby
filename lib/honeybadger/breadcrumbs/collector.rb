require 'forwardable'

module Honeybadger
  module Breadcrumbs
    class Collector
      include Enumerable
      extend Forwardable
      # The Collector manages breadcrumbs and provides an interface for accessing
      # and affecting breadcrumbs
      #
      # Most actions are delegated to the current buffer implementation. A
      # Buffer must implement all delegated methods to work with the Collector.

      # Flush all breadcrumbs, delegates to buffer
      def_delegator :@buffer, :clear!

      # Iterate over all Breadcrumbs and satify Enumerable, delegates to buffer
      # @yield [Object] sequentially gives breadcrumbs to the block
      def_delegator :@buffer, :each

      # Raw Array of Breadcrumbs, delegates to buffer
      # @return [Array] Raw set of breadcrumbs
      def_delegator :@buffer, :to_a

      def initialize(config, buffer = RingBuffer.new)
        @config = config
        @buffer = buffer
      end

      # Add Breadcrumb to stack
      #
      # @return [self] Filtered breadcrumbs
      def add!(breadcrumb)
        return unless @config[:'breadcrumbs.enabled']
        @buffer.add!(breadcrumb)

        self
      end

      alias_method :<<, :add!

      # All active breadcrumbs you want to remove a breadcrumb from the trail,
      # then you can selectively ignore breadcrumbs while building a notice.
      #
      # @return [Array] Active breadcrumbs
      def trail
        select(&:active?)
      end

      def to_h
        {
          enabled: @config[:'breadcrumbs.enabled'],
          trail: trail.map(&:to_h)
        }
      end
    end
  end
end
