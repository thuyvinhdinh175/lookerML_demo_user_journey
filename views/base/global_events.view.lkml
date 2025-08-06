include: "/views/base/base_events.view.lkml"

view: global_events {
  extends: [base_events]
  derived_table: {
    # Use datagroup
    datagroup_trigger: daily_refresh
    
    sql: (
      SELECT 
        *,
        DATE(time) as event_date,
        EXTRACT(HOUR FROM time) as event_hour,
        'global' as country  # Default country value
      FROM main_production.all_events
      WHERE time > CURRENT_DATE - INTERVAL '90 days'
    ) ;;
  }
}