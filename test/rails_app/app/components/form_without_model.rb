class FormWithoutModel < Netzke::Basepack::FormPanel
  def configuration
    super.merge(
      :file_upload => true,
      :items => [
        :text_field,
        {:name => :number_field, :attr_type => :integer},
        {:name => :boolean_field, :attr_type => :boolean, :input_value => true},
        {:name => :date_field, :attr_type => :date},
        {:name => :datetime_field, :attr_type => :datetime},
        {:name => :combobox_field, :xtype => :combo, :store => [[1, "One"], [2, "Two"], [3, "Three"]]},
      ]
    )
  end

  def netzke_submit_endpoint(params)
    data = ActiveSupport::JSON.decode(params[:data])
    {:feedback => data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")}
  end
end
