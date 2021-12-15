module ArticleSearchHelper
  def article_search_pagination(result, options = {}, &block)
    ArticleSearchPaginator.new(result, options).render(&block)
  end

  class ArticleSearchPaginator
    attr_reader :result, :options, :search_form
    def initialize(search_form, options = {}, &block)
      @search_form = search_form
      @result = search_form.result
      @options = options
    end

    def render(&block)
      yield self
    end

    def prev_page
      if options[:prev_page] && current_page > 1
        page = Page.new(current_page - 1, options)
        page.as_prev_page!
        yield page
      end
    end

    def first_page
      if options[:first_page] && current_page > 1
        page = Page.new(1, options)
        page.as_first_page!
        yield page unless page.in_surround?
      end
    end

    def next_page
      if options[:next_page] && current_page < last_page_number
        page = Page.new(current_page + 1, options)
        page.as_next_page!
        yield page
      end
    end

    def last_page
      if options[:first_page] && current_page < last_page_number
        page = Page.new(last_page_number, options)
        page.as_last_page!
        yield page unless page.in_surround?
      end
    end

    def first_ellipsis
      if 1.upto(current_page).any? { |n| !Page.new(n, options).in_surround? }
        yield
      end
    end

    def last_ellipsis
      if current_page.upto(last_page_number).any? { |n| !Page.new(n, options).in_surround? }
        yield
      end
    end

    def in_surround(&block)
      pages = 1.upto(last_page_number).filter_map do |n|
        page = Page.new(n, options)
        if page.in_surround?
          page
        end
      end
      pages.each(&block)
    end

    def all_pages(&block)
      pages = 1.upto(last_page_number).map { |n| Page.new(n, options) }
      pages.each(&block)
    end

    private

    def total_count
      result.response.dig('hits', 'total', 'value')
    end

    def from
      from = result.search.definition.dig(:body, :from)
    end

    def size
      size = result.search.definition.dig(:body, :size)
    end

    def current_page
      ( from / size ) + 1
    end

    def last_page_number
      total_count.fdiv(size).ceil
    end

    DEFAULT_OPTIONS = {
      first_page: true,
      last_page: true,
      prev_page: true,
      next_page: true,
      surround: 5,
    }
    def options
      DEFAULT_OPTIONS.merge(@options).merge({
        form_conditions: form_conditions,
        current_page: current_page,
        last_page_number: last_page_number
      })
    end


    def form_conditions
      search_form.attributes
    end


    class Page
      attr_reader :number, :form_conditions, :options
      def initialize(number, options)
        @number = number
        @form_conditions = options.delete(:form_conditions)
        @options = options
      end

      def form_conditions
        @form_conditions.merge("page" => number)
      end

      def last?
        options[:last_page_number] == number
      end

      def first?
        number == 1
      end

      def current?
        options[:current_page] == number
      end

      def in_surround?
        if options[:current_page] - 1  < options[:surround] / 2
          number <= options[:surround]
        elsif options[:last_page_number] - options[:current_page] < options[:surround] / 2
          options[:last_page_number] - number <= options[:surround]
        else
          (options[:current_page] - number).abs < (options[:surround] / 2) + 1
        end
      end

      [:prev_page, :next_page, :first_page, :last_page].each do |key|
        define_method(:"as_#{key}!") do
          @as = key
        end

        define_method(:"as_#{key}?") do
          @as == key
        end
      end
    end
  end
end
