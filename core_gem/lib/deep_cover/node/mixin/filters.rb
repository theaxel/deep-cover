# frozen_string_literal: true

module DeepCover
  module Node::Mixin
    module Filters
      module ClassMethods
        def filter_to_method_name(kind)
          :"is_#{kind}?"
        end

        def create_filter(name, &block)
          Filters.define_method(filter_to_method_name(name), &block)
          OPTIONALLY_COVERED << name
        end

        def unique_filter
          (1..Float::INFINITY).each do |i|
            name = :"custom_filter_#{i}"
            return name unless Filters.method_defined?(filter_to_method_name(name))
          end
        end
      end

      RAISING_MESSAGES = %i[raise exit].freeze
      def is_raise?
        is_a?(Node::Send) && RAISING_MESSAGES.include?(message) && receiver == nil
      end

      def is_warn?
        is_a?(Node::Send) && message == :warn
      end

      def is_default_argument?
        parent.is_a?(Node::Optarg) && simple_literal?
      end

      def is_case_implicit_else?
        is_a?(Node::EmptyBody) && parent.is_a?(Node::Case) && !parent.has_else?
      end

      def is_trivial_if?
        # Supports only node being a branch or the fork itself
        parent.is_a?(Node::If) && parent.condition.simple_literal?
      end
    end
  end
end
