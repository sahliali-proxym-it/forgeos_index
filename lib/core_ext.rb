def get_all_models
  Module.constants.select do |constant_name|
    constant = eval constant_name
    if not constant.nil? and constant.is_a? Class and constant.superclass == ActiveRecord::Base
      constant
    end
  end
end

def get_models_to_indexes
  get_all_models.find_all {|model| model.constantize.table_exists? && model_is_valid_to_indexes?(model) && !model_has_sphinx_indexes?(model)}.sort
end

# Method to Wirite the Indexer Model
# The model can be generated only if has attributes and has a minimum one string type
# Else the model is desactivated
def write_file_models_indexer
  cleanup  
  models = IndexTable.activated
  unless models.empty?    
    models.each do |model|
      code = ""
      attributes = model.index_table_fields      
      unless attributes.empty?
        if model.has_a_minimum_one_string_type?
          code += "class Indexer#{model.table_name.constantize} < #{model.table_name.constantize} \n"
          code += "\t define_index do \n"
          attributes.each { |attribute| code += get_index_method(model.table_name, attribute.field_name) }
          code += "\t end \n"
          code += "end \n\n"
          File.open(get_file_name(model.table_name), 'w') {|f| f.write(code) }
        else
          model.desactivate!
        end
      end           
    end   
  end
end

# Method to get file name
def get_file_name(model_name)
  "vendor/plugins/forgeos_core/app/models/Indexer#{model_name}".underscore + ".rb"
end

# Method to delete Indexer Model if exist
def cleanup
  IndexTable.all.each do |model|
    File.delete(get_file_name(model.table_name)) if File.exist?(get_file_name(model.table_name))
  end
end

# Méthod to get type of column name
def get_type_column(model_name, column_name)
  model_name.constantize.columns.detect{|elt| elt.name == column_name}.type rescue nil
end

# generate code line in define_index :
# indexes column_name if string or text, and has column_name if integer, date, datetime or boolean
def get_index_method(model_name, column_name)
  type_column = get_type_column(model_name, column_name)
  code_index = ""
  if type_column
    if(type_column == :string || type_column == :text)
      code_index = "\t\t indexes #{column_name} \n"
    elsif(type_column == :integer || type_column == :date || type_column == :datetime || type_column == :boolean)
      code_index = "\t\t has #{column_name} \n"
    end
  end
  code_index
end

# Method that check whether the model can be indexed, the model must have at least one field of type string or text
def model_is_valid_to_indexes?(model_name)
  ignored_models = ["IndexTableField", "IndexTable"]
  return false if ignored_models.include?(model_name)
  types = model_name.constantize.columns.map(&:type)
  unless types.empty?
    types.include?(:string) || types.include?(:text)
  else
    return false
  end
end

# Method that checks if the model already contains a method define_index
def model_has_sphinx_indexes?(model_name)
  model_name.constantize.has_sphinx_indexes?
end

# Method to get all attributes for model name
def get_all_attributes_for_model(model_name)
  return model_name.constantize.column_names
end



