class AddReferencePageSizeToPages < ActiveRecord::Migration[6.0]
  def change
    add_reference :pages, :page_size
  end
end
