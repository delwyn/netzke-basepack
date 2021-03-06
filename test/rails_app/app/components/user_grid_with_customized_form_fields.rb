class UserGridWithCustomizedFormFields < Netzke::Basepack::GridPanel
  js_property :title, "Users"
  config :model => "User"

  def default_fields_for_forms
    [
      {:xtype => 'fieldset', :title => "Basic Info", :checkboxToggle => true, :items => [
        :first_name,
        {:name => :last_name}
      ]},
      {:xtype => 'fieldset', :title => "Timestamps", :items => [
        {:name => :created_at, :disabled => true},
        {:name => :updated_at, :disabled => true}
      ]},
      :role__name
    ]
  end
end
