module SimpleForm
  module Input

    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def boolean_collection
        i18n_cache :boolean_collection do
          [ [I18n.t(:"simple_form.true", :default => 'Yes'), true],
            [I18n.t(:"simple_form.false", :default => 'No'), false] ]
        end
      end
    end

    private

      def generate_input
        html_options = @options[:html] || {}
        html_options[:class] = default_css_classes(html_options[:class])
        @options[:options] ||= {}

        mapping = self.class.mappings[@input_type]
        raise "Invalid input type #{@input_type.inspect}" unless mapping

        args = [ @attribute ]

        if mapping.collection
          collection = @options[:collection] || self.class.boolean_collection
          detect_collection_methods(collection, @options)
          args.push(collection, @options[:value_method], @options[:label_method])
        end

        args << @options[:options] if mapping.options
        args << html_options

        send(mapping.method, *args)
      end

      def detect_collection_methods(collection, options)
        sample = collection.first

        if sample.is_a?(Array) # TODO Test me
          options[:label_method] ||= :first
          options[:value_method] ||= :last
        elsif sample.is_a?(String) # TODO Test me
          options[:label_method] ||= :to_s
          options[:value_method] ||= :to_s
        else # TODO Implement collection label methods or something similar
          options[:label_method] ||= :to_s
          options[:value_method] ||= :to_s
        end
      end

      def collection_radio(attribute, collection, value_method, text_method, html_options={})
        collection.inject('') do |result, item|
          value = item.send value_method
          text  = item.send text_method

          result << radio_button(attribute, value, html_options) <<
                    label("#{attribute}_#{value}", text, :class => "radio")
        end
      end

  end
end