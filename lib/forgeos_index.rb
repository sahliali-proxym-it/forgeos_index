require "core_ext"
require "routing"

%w{ models controllers helpers}.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.send :helper, IndexersHelper


unless IndexTable.table_exists?
  ActiveRecord::Schema.create_table(IndexTable.table_name) do |t|
    t.column :table_name, :string
    t.column :activated, :boolean, :default => false
    t.column :created_at,     :datetime
    t.column :updated_at,     :datetime
  end
end


unless IndexTableField.table_exists?
  ActiveRecord::Schema.create_table(IndexTableField.table_name) do |t|
    t.column :field_name, :string
    t.column :index_table_id, :integer
    t.column :created_at,     :datetime
    t.column :updated_at,     :datetime
  end
end