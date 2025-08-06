include: "/views/base/base_events.view.lkml"

view: uk_events {
  extends: [base_events]
  derived_table: {
    # Use datagroup
    datagroup_trigger: daily_refresh
    
    sql: (
      SELECT 
        *,
        DATE(time) as event_date,
        EXTRACT(HOUR FROM time) as event_hour,
        'UK' as country
      FROM main_production.all_events  # Replace with UK-specific table if available
      WHERE time > CURRENT_DATE - INTERVAL '90 days'
      AND country = 'UK'  # Filter for UK data
    ) ;;
  }
}