# frozen_string_literal: true
class HistoriesController < ApplicationController
  def show
    @history = History.find(params[:id])
  end
end
