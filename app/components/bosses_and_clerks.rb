class BossesAndClerks < Netzke::Basepack::BorderLayoutPanel

  def configuration
    super.merge(
      :header => false,
      :items => [
        {
          :name => "bosses",
          :class_name => "Netzke::Basepack::GridPanel",
          :model => "Boss",
          :region => :center,
          :title => 'Bosses',
        },{
          :name => "info",
          :class_name => "Netzke::Basepack::Panel",
          :region => :east,
          :title  => 'Info',
          :width => 240,
          :split => true
        },
        :clerks.component(
          :region => :south,
          :title => "Clerks",
          :height => 150,
          :split => true
        )
      ]
    )
  end

  component :clerks do
    {
      :class_name => "Netzke::Basepack::GridPanel",
      :model => "Clerk",

      # do not load data initially
      :load_inline_data => false,
      
      # limit the scope to the selected boss (see below)
      :scope => {:boss_id => component_session[:selected_boss_id]},
      
      # always set boss_id
      :strong_default_attrs => {:boss_id => component_session[:selected_boss_id]}
    }
  end

  endpoint :select_boss do |params|
    # store selected boss id in the session for this component's instance
    component_session[:selected_boss_id] = params[:boss_id]
   
    # selected boss
    boss = Boss.find(params[:boss_id])
    clerks_grid = component_instance(:clerks)
    clerks_data = clerks_grid.get_data
   
    {
      :clerks => {:load_store_data => clerks_data, :set_title => "Clerks for #{boss.name}"},
      :info => {:update_body_html => boss_info_html(boss), :set_title => "#{boss.name}"}
    }
  end
 
  def boss_info_html(boss)
    res = "<h1>Statistics on clerks</h1>"
    res << "Number: #{boss.clerks.count}<br/>"
    res << "With salary > $5,000: #{boss.clerks.where(:salary.gt => 5000).count}<br/>"
    res << "To lay off: #{boss.clerks.where(:subject_to_lay_off => true).count}<br/>"
    res
  end
 
  # Overriding initComponent
  js_method :init_component, <<-JS
    function(){
      // calling superclass's initComponent
      #{js_full_class_name}.superclass.initComponent.call(this);
  
      // setting the 'rowclick' event
      this.getChildComponent('bosses').on('rowclick', this.onBossSelectionChanged, this);
    }
  JS
  
  # Event handler
  js_method :on_boss_selection_changed, <<-JS
    function(self, rowIndex){
      this.selectBoss({boss_id: self.store.getAt(rowIndex).get('id')});
    }
  JS
 
end
