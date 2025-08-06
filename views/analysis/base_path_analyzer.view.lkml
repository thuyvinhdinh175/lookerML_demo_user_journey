view: base_path_analyzer {
  extension: required
  
  filter: first_event_selector {
    description: "The name of the event starting the path you would like to analyze."
    view_label: "Control Panel"
    type: string
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  filter: last_event_selector {
    description: "The name of the event ending the path you would like to analyze."
    view_label: "Control Panel"
    type: string
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  dimension: path {
    primary_key: yes
    type: string
    sql: ${TABLE}.path ;;
  }

  dimension: step_1 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 1) ;;
  }

  dimension: step_2 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 2) ;;
  }

  dimension: step_3 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 3) ;;
  }

  dimension: step_4 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 4) ;;
  }

  dimension: step_5 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 5) ;;
  }

  dimension: step_6 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 6) ;;
  }

  dimension: step_7 {
    type: string
    sql: SPLIT_PART(${TABLE}.path, '- ', 7) ;;
  }

  measure: total_sessions {
    description: "Total sessions with this path"
    type: sum
    sql: ${TABLE}.count ;;
  }
}