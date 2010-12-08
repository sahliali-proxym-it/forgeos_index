module IndexersHelper
  def get_html_options_for_model
    html = ""
    unless @models.empty?
      @models.each do |model_name|
        html += '<div class="option-panel">'
        html += '<div class="backgrounds content-header"></div>'
        checked = IndexTable.is_activated?(model_name)
        html += link_to("<div style='color:#{checked ? 'green' : '#000000' }'>#{model_name}</div>",
          "#", :class => "small-icons panel")        
        attributes = get_all_attributes_for_model(model_name)
        if attributes.count > 0
          html += '<div class="option-panel-content">'
           html += '<div> Activer ou Désactiver ce model : '
            html += check_box_tag 'models[]', model_name , checked, {:id => "models"}
            html += "</div>"
          html += "<ul>"
          attributes.each do |attribute|
           
            html += "<div>"
            checked = IndexTable.get_indexes_attributes(model_name).map(&:field_name).include?(attribute)
            html += check_box_tag("index_table[#{model_name}][]", attribute,  checked)
            html += "#{attribute} "
            html += "</div>"
          end
          html += "</ul>"
          html += "</div>"
          html += "</div>"
        end

       
      end
    end
    html
  end
end
