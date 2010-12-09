class IndexTable < ActiveRecord::Base

  has_many :index_table_fields
  named_scope :activated, :conditions => ["activated = true"]

  def self.get_indexes_attributes(model_name)
    record = find_by_table_name(model_name)
    record ? record.index_table_fields : []
  end

  def self.is_activated?(model_name)
    record =  find_by_table_name(model_name)
    record ? record.activated : false
  end

  def self.exist_table?(model_name)    
    find_by_table_name(model_name) ? true : false
  end

  def self.create_or_update_attributes(options)   
    descativate_models
    if options[:models]
      options[:models].each do |model_name|
        index_table = find_by_table_name(model_name)
        if index_table
          index_table.activate!
          index_table.remove_uncheked_fields
        else
          IndexTable.create(:table_name => model_name, :activated => true)
        end
      end
    end
 
    if options[:index_table]
      options[:index_table].each do |k, v|
        index_table = find_or_create_by_table_name(k)
        if index_table
          index_table.remove_uncheked_fields         
          index_table.add_cheked_fields(v)
        end
      end
    end
  end

  def self.descativate_models
    find_all_by_activated(true).each {|index_table| index_table.desactivate!}
  end

  def activate!
    update_attribute(:activated, true)
  end

  def desactivate!
    update_attribute(:activated, false)
  end

  def add_cheked_fields(fields)
    if fields && fields.count > 0
      fields.each do |field_name|
        self.index_table_fields.build(:field_name => field_name)
        self.save
      end
    end
  end

  def remove_uncheked_fields()
    self.index_table_fields.each {|elt| elt.destroy}
  end

  
  # Method that checks if the model contains at least an indexer on a string or a text type
  def has_a_minimum_one_string_type?
    self.index_table_fields.map(&:field_name).each do |field_name|
      self.table_name.constantize.content_columns.each {|elt| return true if (elt.name == field_name && (elt.type == :string || elt.type == :text))}      
    end
    return false
  end
end
