require 'csv'

class Foo::BarCsv
  private_class_method :new

  def self.call(*args)
    new(*args).call
  end

  def initialize; end

  def call
    ::CSV.generate do |csv|
      csv << ['foo']
      csv << ['bar']
    end
  end
end
