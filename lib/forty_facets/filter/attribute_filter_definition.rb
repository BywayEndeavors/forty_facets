module FortyFacets
  class AttributeFilterDefinition < FilterDefinition
    class AttributeFilter < Filter
      def build_scope
        return Proc.new { |base| base } if empty?
        Proc.new {  |base| base.where(filter_definition.model_field => value) }
      end

      def facet
        my_column = filter_definition.model_field
        counts = without.result.reorder('').select("#{my_column} AS facet_value, count(#{my_column}) as occurrences").group(my_column)
        counts.map{|c| FacetValue.new(c.facet_value, c.occurrences, false)}
      end

      def remove(value)
        new_params = search_instance.params || {}
        old_values = new_params[filter_definition.request_param]
        old_values.delete(value.to_s)
        new_params.delete(filter_definition.request_param) if old_values.empty?
        search_instance.class.new_unwrapped(new_params)
      end

      def add(value)
        new_params = search_instance.params || {}
        old_values = new_params[filter_definition.request_param] ||= []
        old_values << value.to_s
        search_instance.class.new_unwrapped(new_params)
      end
    end

    def build_filter(search_instance, value)
      AttributeFilter.new(self, search_instance, value)
    end
  end
end
