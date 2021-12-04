class EntriesController < ApplicationController
  before_action :set_entry, only: %i[ show create_history ]
  def index
    @entries = Entry.all
  end

  def show; end

  def create_history
    CreateHistoryJob.perform_later(@entry)
  end

  private

  def set_entry
    @entry = Entry.find params[:id]
  end
end
