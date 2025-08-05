include: "/views/intermediate/event_string_length.view.lkml"
include: "/views/intermediate/all_unique_events.view.lkml"

view: session_paths {
  derived_table: {
    # Implement materialized view for better performance
    materialized: yes
    
    # Use datagroup instead of direct SQL trigger
    datagroup_trigger: daily_refresh
    
    # Add indexes for better query performance
    indexes: ["user_id", "session_id", "path"]
    
    # Distribution key for better query performance
    distribution: "user_id"
    
    sql:
      SELECT
          aue.user_id
        , aue.session_id
        , LISTAGG(aue.event_table_name, ' - ')
            WITHIN GROUP (ORDER BY aue.event_rank) AS path
        , MIN(aue.event_date) AS first_event_date
        , MAX(aue.event_date) AS last_event_date
        , COUNT(*) AS path_length
        , MIN(aue.time) AS first_event_time
        , MAX(aue.time) AS last_event_time
      FROM ${all_unique_events.SQL_TABLE_NAME} aue
      INNER JOIN ${event_string_length.SQL_TABLE_NAME} esl
        ON aue.user_id = esl.user_id
        AND aue.session_id = esl.session_id
        AND aue.event_rank = esl.event_rank
        -- Prevent list-agg character limit overflow errors
        AND esl.cumulative_characters < 65535
      GROUP BY
          aue.user_id
        , aue.session_id
      ;;
  }

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