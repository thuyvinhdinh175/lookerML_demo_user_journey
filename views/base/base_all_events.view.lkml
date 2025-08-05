view: base_all_events {
  derived_table: {
    # Use datagroup
    datagroup_trigger: daily_refresh
    
    sql: (
      SELECT 
        *,
        DATE(time) as event_date,
        EXTRACT(HOUR FROM time) as event_hour
      FROM main_production.all_events
      WHERE time > CURRENT_DATE - INTERVAL '90 days'
    ) ;;
  }

  # Add dimensions for the base event data
  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    description: "Unique identifier for the user"
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
    description: "Unique identifier for the session"
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
    description: "Unique identifier for the event"
    primary_key: yes
  }

  dimension: event_table_name {
    type: string
    sql: ${TABLE}.event_table_name ;;
    description: "Name of the event"
  }

  dimension_group: event {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      hour_of_day,
      day_of_week
    ]
    sql: ${TABLE}.time ;;
    description: "When the event occurred"
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
    description: "Date of the event (for incremental processing)"
  }

  dimension: event_hour {
    type: number
    sql: ${TABLE}.event_hour ;;
    description: "Hour of the event (for time-based analysis)"
  }
}