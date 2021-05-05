# frozen_string_literal: true
module Connections
  class ElasticsearchConnection < GraphQL::Pagination::Connection
    def nodes
      paged_nodes_array
    end

    def has_next_page
      total = total_count

      if total_count && paged_nodes.from.present? && paged_nodes.size.present?
        (paged_nodes.from + paged_nodes.size) < total
      else
        false
      end
    end

    def has_previous_page
      total = total_count

      if total && paged_nodes.from.present? && paged_nodes.size.present?
        from_cursor = paged_nodes.from - paged_nodes.size
        0 <= from_cursor && from_cursor <= total
      else
        false
      end
    end

    def total_count
      @total_count ||= sliced_nodes.total_count
    end

    def facets
      @facets ||= sliced_nodes.facets
    end

    def cursor_for(item)
      offset = nodes.index(item) + 1 + (@paged_nodes.from || 0)
      encode(offset.to_s)
    end

    private

      def sliced_nodes
        @sliced_nodes ||= begin
          sliced_nodes = items

          if after_offset
            sliced_nodes.from = after_offset
          end

          if before_offset && after_offset
            sliced_nodes.size = if after_offset < before_offset
              before_offset - after_offset - 1
            else
              0
            end
          elsif before_offset
            sliced_nodes.size = before_offset - 1
          end
          sliced_nodes
        end
      end

      def paged_nodes
        @paged_nodes ||= begin
          paged_nodes = sliced_nodes

          if first
            paged_nodes.size = first
          end

          if last
            if paged_nodes.size
              if last <= paged_nodes.size
                from = paged_nodes.from + paged_nodes.size - last
                paged_nodes.from = from
                paged_nodes.size = last
              end
            else
              from = [(paged_nodes.from || 0), total_count - last].max
              paged_nodes.from = from
              paged_nodes.size = last
            end
          end
          paged_nodes
        end
      end

      def paged_nodes_array
        @paged_nodes_array ||= paged_nodes.array
      end

      def offset_from_cursor(cursor)
        decode(cursor).to_i
      end

      def before_offset
        @before_offset ||= before && offset_from_cursor(before)
      end

      def after_offset
        @after_offset ||= after && offset_from_cursor(after)
      end
  end
end
