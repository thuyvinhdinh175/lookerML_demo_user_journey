include: "/views/intermediate/event_string_length.view.lkml"
include: "/views/intermediate/us_unique_events.view.lkml"
include: "/views/paths/base_session_paths.view.lkml"

view: us_session_paths {
  extends: [base_session_paths]
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
        , aue.country  -- Include country field
      FROM ${us_unique_events.SQL_TABLE_NAME} aue
      INNER JOIN ${event_string_length.SQL_TABLE_NAME} esl
        ON aue.user_id = esl.user_id
        AND aue.session_id = esl.session_id
        AND aue.event_rank = esl.event_rank
        -- Prevent list-agg character limit overflow errors
        AND esl.cumulative_characters < 65535
      GROUP BY
          aue.user_id
        , aue.session_id
        , aue.country  -- Include in GROUP BY
      ;;
  }
}