require 'csv'

module CsvsHelper
  class HogeCsv
    private_class_method :new
    def self.call(*args)
      new(*args).call
    end

    def initialize; end

    def call
      ::CSV.generate do |csv|
        csv << ['hoge']
        csv << ['piyo']
      end
    end
  end

  def hoge_piyo_csv
    HogeCsv.call
  end
end
