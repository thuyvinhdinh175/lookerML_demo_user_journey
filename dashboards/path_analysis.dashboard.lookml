- dashboard: path_analysis
  title: User Journey Path Analysis
  layout: newspaper
  preferred_viewer: dashboards-next
  description: 'Analyze user journeys and paths through your application'
  
  filters:
  - name: date_range
    title: 'Date Range'
    type: field_filter
    default_value: 30 days
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
      options: []
    model: journeys
    explore: path_analyzer
    field: session_paths.first_event_date
  
  - name: first_event
    title: 'Starting Event'
    type: field_filter
    default_value: ''
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: journeys
    explore: path_analyzer
    field: path_analyzer.first_event_selector
  
  - name: last_event
    title: 'Ending Event'
    type: field_filter
    default_value: ''
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: journeys
    explore: path_analyzer
    field: path_analyzer.last_event_selector

  elements:
  - name: top_paths
    title: 'Top User Paths'
    model: journeys
    explore: path_analyzer
    type: looker_bar
    fields: [path_analyzer.path, path_analyzer.total_sessions]
    sorts: [path_analyzer.total_sessions desc]
    limit: 15
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: path_analyzer.total_sessions, id: path_analyzer.total_sessions, name: Total Sessions}], showLabels: true, showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_label: Path
    series_types: {}
    defaults_version: 1
    listen:
      date_range: session_paths.first_event_date
      first_event: path_analyzer.first_event_selector
      last_event: path_analyzer.last_event_selector
    row: 0
    col: 0
    width: 24
    height: 8
    
  - name: event_popularity
    title: 'Event Popularity'
    model: journeys
    explore: event_counts
    type: looker_pie
    fields: [event_counts.event_table_name, event_counts.count]
    sorts: [event_counts.count desc]
    limit: 10
    value_labels: legend
    label_type: labPer
    inner_radius: 50
    series_colors: {}
    series_labels: {}
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    defaults_version: 1
    row: 8
    col: 0
    width: 12
    height: 8
    
  - name: path_length_distribution
    title: 'Path Length Distribution'
    model: journeys
    explore: path_analyzer
    type: looker_column
    fields: [session_paths.path_length, session_paths.count]
    sorts: [session_paths.path_length]
    limit: 20
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: 'Number of Sessions', orientation: left, series: [{axisId: session_paths.count, id: session_paths.count, name: Count}], showLabels: true, showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_label: Path Length (Number of Events)
    series_types: {}
    defaults_version: 1
    listen:
      date_range: session_paths.first_event_date
    row: 8
    col: 12
    width: 12
    height: 8
    
  - name: funnel_analysis
    title: 'Conversion Funnel'
    model: journeys
    explore: funnel_analysis
    type: looker_column
    fields: [funnel_analysis.count_step1, funnel_analysis.count_step2, funnel_analysis.count_step3, funnel_analysis.count_step4]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: 'Number of Users', orientation: left, series: [{axisId: funnel_analysis.count_step1, id: funnel_analysis.count_step1, name: Step 1}, {axisId: funnel_analysis.count_step2, id: funnel_analysis.count_step2, name: Step 2}, {axisId: funnel_analysis.count_step3, id: funnel_analysis.count_step3, name: Step 3}, {axisId: funnel_analysis.count_step4, id: funnel_analysis.count_step4, name: Step 4}], showLabels: true, showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_label: Funnel Step
    series_types: {}
    series_colors: {}
    defaults_version: 1
    listen:
      date_range: funnel_analysis.first_event_date
    row: 16
    col: 0
    width: 24
    height: 8