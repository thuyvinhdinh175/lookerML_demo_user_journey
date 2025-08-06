include: "/views/intermediate/us_unique_events.view.lkml"
include: "/views/paths/example_paths.view.lkml"
include: "/views/intermediate/event_string_length.view.lkml"
include: "/views/paths/base_exploded_paths.view.lkml"

view: us_exploded_paths {
  extends: [base_exploded_paths]
  derived_table: {
    datagroup_trigger: daily_refresh
    sql:
        SELECT
            ep.path
          , aue.event_table_name
          , aue.event_rank
          , aue.country  -- Include country field
          , esl.cumulative_characters
        FROM ${us_unique_events.SQL_TABLE_NAME} aue
        INNER JOIN ${example_paths.SQL_TABLE_NAME} ep
          ON aue.user_id = ep.user_id
            AND aue.session_id = ep.session_id
        INNER JOIN ${event_string_length.SQL_TABLE_NAME} esl
          ON aue.user_id = esl.user_id
          AND aue.session_id = esl.session_id
          AND aue.event_rank = esl.event_rank
          -- Prevent list-agg character limit overflow errors
          AND esl.cumulative_characters < 65535
        WHERE aue.country = 'US'  -- Filter for US data
          ;;
  }
}