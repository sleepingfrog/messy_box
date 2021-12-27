class CsvsController < ApplicationController

  def index; end

  def one
    respond_to do |format|
      format.csv do
        send_data Foo::BarCsv.call, filename: "foobar.csv"
      end
    end
  end

  def two
    respond_to do |format|
      format.csv do
        send_data render_to_string, type: :csv, filename: "hoge.csv"
      end
    end
  end
end
