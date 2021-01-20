module Connections
  class ElasticsearchConnection < GraphQL::Relay::BaseConnection
    def cursor_from_node(item)
      item_index = paged_nodes_array.index(item)
      if item_index.nil?
        raise("Can't generate cursor, item not found in connection: #{item}")
      else
        offset = paged_nodes.from + item_index + 1
        encode(offset.to_s)
      end
    end

    def has_next_page
      es_total = total_count

      if es_total && paged_nodes.from.present? && paged_nodes.size.present?
        return (paged_nodes.from + paged_nodes.size) < es_total
      else
        return false
      end
    end

    def has_previous_page
      es_total = total_count

      if es_total && paged_nodes.from.present? && paged_nodes.size.present?
        from_cursor = paged_nodes.from - paged_nodes.size
        return 0 <= from_cursor && from_cursor <= es_total
      else
        return false
      end
    end

    def total_count
      @total_count ||= sliced_nodes.total_count
    end

    def facets
      @facets ||= sliced_nodes.facets
    end

    private

      def paged_nodes
        return @paged_nodes if defined? @paged_nodes

        items = sliced_nodes

        if first
          items.size = first
        end

        if last
          if items.size
            if last <= items.size
              from = items.from + items.size - last
              items.from = from
              items.size = last
            end
          else
            from = items.from + total_count  - [last, total_count].min
            items.from = from
            items.size = last
          end
        end
        @paged_nodes = items

        @paged_nodes
      end

      def sliced_nodes
        return @sliced_nodes if defined? @sliced_nodes

        @sliced_nodes = nodes

        if after
          after_i = offset_from_cursor(after)
          @sliced_nodes.from = after_i
        end

        if before && after
          if offset_from_cursor(after) < offset_from_cursor(before)
            @sliced_nodes.size = offset_from_cursor(before) - offset_from_cursor(after) - 1
          else
            @sliced_nodes.size = 0
          end

        elsif before
          @sliced_nodes.size = offset_from_cursor(before) - 1
        end

        @sliced_nodes
      end

      def offset_from_cursor(cursor)
        decode(cursor).to_i
      end

      def paged_nodes_array
        return @paged_nodes_array if defined?(@paged_nodes_array)
        @paged_nodes_array = paged_nodes.array
      end
  end
end
