include: "/views/paths/exploded_paths.view.lkml"
include: "/views/paths/session_paths.view.lkml"

view: funnel_analysis {
  derived_table: {
    # Implement materialized view for better performance
    materialized: yes
    
    # Use datagroup instead of direct SQL trigger
    datagroup_trigger: daily_refresh
    
    sql: WITH funnel_steps AS (
      SELECT
          ep.path
        , ep.event_table_name
        , ep.event_rank
        , sp.user_id
        , sp.session_id
        , sp.first_event_date
      FROM ${exploded_paths.SQL_TABLE_NAME} ep
      JOIN ${session_paths.SQL_TABLE_NAME} sp
        ON ep.path = sp.path
    )
    
    SELECT
        fs1.path
      , fs1.user_id
      , fs1.session_id
      , fs1.first_event_date
      , fs1.event_table_name AS step1_event
      , fs1.event_rank AS step1_rank
      , fs2.event_table_name AS step2_event
      , fs2.event_rank AS step2_rank
      , fs3.event_table_name AS step3_event
      , fs3.event_rank AS step3_rank
      , fs4.event_table_name AS step4_event
      , fs4.event_rank AS step4_rank
      , CASE WHEN fs2.event_table_name IS NOT NULL THEN 1 ELSE 0 END AS converted_to_step2
      , CASE WHEN fs3.event_table_name IS NOT NULL THEN 1 ELSE 0 END AS converted_to_step3
      , CASE WHEN fs4.event_table_name IS NOT NULL THEN 1 ELSE 0 END AS converted_to_step4
    FROM funnel_steps fs1
    LEFT JOIN funnel_steps fs2
      ON fs1.path = fs2.path
      AND fs1.user_id = fs2.user_id
      AND fs1.session_id = fs2.session_id
      AND fs2.event_rank = fs1.event_rank + 1
    LEFT JOIN funnel_steps fs3
      ON fs2.path = fs3.path
      AND fs2.user_id = fs3.user_id
      AND fs2.session_id = fs3.session_id
      AND fs3.event_rank = fs2.event_rank + 1
    LEFT JOIN funnel_steps fs4
      ON fs3.path = fs4.path
      AND fs3.user_id = fs4.user_id
      AND fs3.session_id = fs4.session_id
      AND fs4.event_rank = fs3.event_rank + 1
    WHERE fs1.event_rank = 1
    ;;
  }

  filter: funnel_step1 {
    type: string
    description: "First step in the funnel"
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  filter: funnel_step2 {
    type: string
    description: "Second step in the funnel"
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  filter: funnel_step3 {
    type: string
    description: "Third step in the funnel"
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  filter: funnel_step4 {
    type: string
    description: "Fourth step in the funnel"
    suggest_explore: event_counts
    suggest_dimension: event_counts.event_table_name
  }

  dimension: path {
    type: string
    sql: ${TABLE}.path ;;
    description: "Complete path of events"
  }

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
  
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    sql: ${user_id} || '-' || ${session_id} ;;
  }
  
  dimension_group: first_event {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.first_event_date ;;
    description: "Date of the first event in the path"
  }

  dimension: step1_event {
    type: string
    sql: ${TABLE}.step1_event ;;
    description: "First event in the path"
  }

  dimension: step2_event {
    type: string
    sql: ${TABLE}.step2_event ;;
    description: "Second event in the path"
  }

  dimension: step3_event {
    type: string
    sql: ${TABLE}.step3_event ;;
    description: "Third event in the path"
  }

  dimension: step4_event {
    type: string
    sql: ${TABLE}.step4_event ;;
    description: "Fourth event in the path"
  }

  dimension: converted_to_step2 {
    type: yesno
    sql: ${TABLE}.converted_to_step2 = 1 ;;
    description: "Whether the path converted to step 2"
  }

  dimension: converted_to_step3 {
    type: yesno
    sql: ${TABLE}.converted_to_step3 = 1 ;;
    description: "Whether the path converted to step 3"
  }

  dimension: converted_to_step4 {
    type: yesno
    sql: ${TABLE}.converted_to_step4 = 1 ;;
    description: "Whether the path converted to step 4"
  }

  measure: count_paths {
    type: count
    description: "Count of unique paths"
  }

  measure: count_step1 {
    type: count
    description: "Count of paths with step 1"
    filters: [step1_event: "-NULL"]
  }

  measure: count_step2 {
    type: count
    description: "Count of paths with step 2"
    filters: [step2_event: "-NULL"]
  }

  measure: count_step3 {
    type: count
    description: "Count of paths with step 3"
    filters: [step3_event: "-NULL"]
  }

  measure: count_step4 {
    type: count
    description: "Count of paths with step 4"
    filters: [step4_event: "-NULL"]
  }

  measure: step1_to_step2_conversion_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_step2} / NULLIF(${count_step1}, 0) ;;
    description: "Conversion rate from step 1 to step 2"
  }

  measure: step2_to_step3_conversion_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_step3} / NULLIF(${count_step2}, 0) ;;
    description: "Conversion rate from step 2 to step 3"
  }

  measure: step3_to_step4_conversion_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_step4} / NULLIF(${count_step3}, 0) ;;
    description: "Conversion rate from step 3 to step 4"
  }

  measure: overall_conversion_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_step4} / NULLIF(${count_step1}, 0) ;;
    description: "Overall conversion rate from step 1 to step 4"
  }
}