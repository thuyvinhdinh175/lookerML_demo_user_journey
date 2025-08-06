view: base_unique_events {
  extension: required
  
  dimension: event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.event_id ;;
    description: "Unique identifier for the event"
  }

  dimension: event_rank {
    type: number
    sql: ${TABLE}.event_rank ;;
    description: "Sequential rank of the event within the session"
  }

  dimension: event_table_name {
    type: string
    sql: ${TABLE}.event_table_name ;;
    description: "Name of the event"
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
    description: "Unique identifier for the session"
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
      year
    ]
    sql: ${TABLE}.time ;;
    description: "When the event occurred"
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    description: "Unique identifier for the user"
  }
  
  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
    description: "Date of the event (for incremental processing)"
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "Country of the user"
  }
}