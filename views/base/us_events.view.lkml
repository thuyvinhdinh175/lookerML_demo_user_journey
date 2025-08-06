include: "/views/base/base_events.view.lkml"

view: us_events {
  extends: [base_events]
  derived_table: {
    # Use datagroup
    datagroup_trigger: daily_refresh
    
    sql: (
      SELECT 
        *,
        DATE(time) as event_date,
        EXTRACT(HOUR FROM time) as event_hour,
        'US' as country
      FROM main_production.all_events  # Replace with US-specific table if available
      WHERE time > CURRENT_DATE - INTERVAL '90 days'
      AND country = 'US'  # Filter for US data
    ) ;;
  }
}