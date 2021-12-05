# frozen_string_literal: true
class EntriesController < ApplicationController
  before_action :set_entry, only: %i[show create_history]
  def index
    @entries = Entry.all
  end

  def show; end

  def create_history
    CreateHistoryJob.perform_later(@entry)

    respond_to do |format|
      format.html { redirect_to(entry_path(@entry), notice: 'Enqueued history job.') }
    end
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to(entry_path(@entry), notice: 'Entry was successfully created.') }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  private

    def set_entry
      @entry = Entry.find(params[:id])
    end

    def entry_params
      params.require(:entry).permit(:url, :wait)
    end
end
