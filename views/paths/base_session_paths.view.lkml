view: base_session_paths {
  extension: required
  
  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.user_id || ${TABLE}.session_id;;
    description: "Unique identifier for the session path"
  }

  dimension: path {
    sql: ${TABLE}.path ;;
    description: "Complete path of events in the session"
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
    description: "Unique identifier for the session"
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    description: "Unique identifier for the user"
  }
  
  dimension: path_length {
    type: number
    sql: ${TABLE}.path_length ;;
    description: "Number of events in the path"
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "Country of the user"
  }
  
  dimension_group: first_event {
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
    sql: ${TABLE}.first_event_time ;;
    description: "When the first event in the path occurred"
  }
  
  dimension_group: last_event {
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
    sql: ${TABLE}.last_event_time ;;
    description: "When the last event in the path occurred"
  }
  
  dimension: session_duration {
    type: number
    sql: DATEDIFF(second, ${TABLE}.first_event_time, ${TABLE}.last_event_time) ;;
    description: "Duration of the session in seconds"
    value_format_name: decimal_0
  }
  
  measure: average_session_duration {
    type: average
    sql: ${session_duration} ;;
    description: "Average duration of sessions in seconds"
    value_format_name: decimal_0
  }
  
  measure: count {
    type: count
    description: "Count of unique session paths"
  }
  
  measure: average_path_length {
    type: average
    sql: ${path_length} ;;
    description: "Average number of events in paths"
    value_format_name: decimal_1
  }
}