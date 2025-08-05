include: "/views/base/base_all_events.view.lkml"
include: "/views/intermediate/event_counts.view.lkml"

view: all_unique_events {
  derived_table: {
    # Implement incremental PDT
    increment_key: "event_date"
    increment_offset: 3  # Days of overlap for safety
    
    # Use datagroup instead of direct SQL trigger
    datagroup_trigger: daily_refresh
    
    # Materialized for better performance
    materialized: yes
    
    sql: 
      {% if _incremental %}
        -- Incremental update logic
        WITH event_selector AS (
          SELECT
              ae.*
            , ROW_NUMBER() OVER (
              PARTITION BY ae.user_id, ae.event_id
              ORDER BY ec.count ASC
            ) AS name_rank
          FROM ${base_all_events.SQL_TABLE_NAME} ae
          LEFT JOIN ${event_counts.SQL_TABLE_NAME} ec
            ON ae.event_table_name = ec.event_table_name
          WHERE ae.event_date >= (SELECT MAX(event_date) FROM ${SQL_TABLE_NAME}) - 3
        )
        
        SELECT
            user_id
          , "time"
          , event_id
          , session_id
          , TRIM(event_table_name) AS event_table_name
          , event_date  -- Include for incremental processing
          , ROW_NUMBER() OVER (
            PARTITION BY user_id, session_id
            ORDER BY "time" ASC
          ) AS event_rank
        FROM event_selector
        WHERE name_rank = 1
      {% else %}
        -- Initial full build
        WITH event_selector AS (
          SELECT
              ae.*
            , ROW_NUMBER() OVER (
              PARTITION BY ae.user_id, ae.event_id
              ORDER BY ec.count ASC
            ) AS name_rank
          FROM ${base_all_events.SQL_TABLE_NAME} ae
          LEFT JOIN ${event_counts.SQL_TABLE_NAME} ec
            ON ae.event_table_name = ec.event_table_name
        )
        
        SELECT
            user_id
          , "time"
          , event_id
          , session_id
          , TRIM(event_table_name) AS event_table_name
          , event_date  -- Include for incremental processing
          , ROW_NUMBER() OVER (
            PARTITION BY user_id, session_id
            ORDER BY "time" ASC
          ) AS event_rank
        FROM event_selector
        WHERE name_rank = 1
      {% endif %}
    ;;
  }

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
}