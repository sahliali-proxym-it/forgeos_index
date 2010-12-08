class Admin::IndexersController < ApplicationController
  layout 'admin'
  before_filter :login_required
  self.append_view_path(File.join(File.dirname(__FILE__), '../..', 'views'))

  def index
    
    @models = get_models_to_indexes
  end

  def create
    IndexTable.create_or_update_attributes(params)
    write_file_models_indexer
    redirect_to admin_indexers_path
  end

end
