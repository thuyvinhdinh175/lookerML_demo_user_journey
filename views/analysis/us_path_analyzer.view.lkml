include: "/views/paths/us_exploded_paths.view.lkml"
include: "/views/analysis/path_counts.view.lkml"
include: "/views/analysis/base_path_analyzer.view.lkml"

view: us_path_analyzer {
  extends: [base_path_analyzer]
  derived_table: {
    sql: WITH
        -- To avoid having to deal with commas in future conditional CTAS
        syntax_ctas AS (SELECT TRUE)

        {% if us_path_analyzer.first_event_selector._in_query %}
        -- Find paths that contain the first event, and locate the first occurrence of that event
          , first_event_selector AS (
            SELECT
                path
              , MIN(event_rank) AS first_occurrence
            FROM ${us_exploded_paths.SQL_TABLE_NAME}
            WHERE event_table_name = {% parameter first_event_selector %}
            GROUP BY
              path
          )
        {% endif %}

        {% if us_path_analyzer.last_event_selector._in_query %}
        -- Find paths that contain the last event, and locate the first occurrence of that event
        , last_event_selector AS (
            SELECT
                ep.path
              , MIN(ep.event_rank) AS first_occurrence
            FROM ${us_exploded_paths.SQL_TABLE_NAME} ep
            {% if us_path_analyzer.first_event_selector._in_query %}
              INNER JOIN first_event_selector fes
              ON ep.path = fes.path AND ep.event_rank > fes.first_occurrence
            {% endif %}
            WHERE event_table_name = {% parameter last_event_selector %}
            GROUP BY
              ep.path
        )
        {% endif %}

        -- Find all paths with the first and last event (and their counts) and create a new path
        -- made up of only the events between the first and last event selected by the user.
        , sub_paths AS (
            SELECT
                pc.count
              , pc.path as orig_path
              , LISTAGG(ep.event_table_name, '- ')
                WITHIN GROUP (ORDER BY ep.event_rank) AS path
            FROM ${us_exploded_paths.SQL_TABLE_NAME} ep
            INNER JOIN ${path_counts.SQL_TABLE_NAME} pc
              ON ep.path = pc.path
            {% if us_path_analyzer.first_event_selector._in_query %}
              INNER JOIN first_event_selector fes
                ON ep.path = fes.path AND ep.event_rank >= fes.first_occurrence
            {% endif %}
            {% if us_path_analyzer.last_event_selector._in_query %}
              INNER JOIN last_event_selector les
                ON ep.path = les.path AND ep.event_rank <= les.first_occurrence
            {% endif %}
            WHERE ep.country = 'US'  -- Filter for US data
            GROUP BY
                pc.count
              , pc.path
          )

      -- Sum everything up to find counts within the sub-path
        , sub_path_summary as (
            SELECT
                path
              , SUM(count) as count
            FROM sub_paths
            GROUP BY
                path
          )

        SELECT
          *,
          'US' as country
        -- If there aren't fitlers selected, go straight to the pre-built table
        FROM {% if us_path_analyzer.last_event_selector._in_query or us_path_analyzer.first_event_selector._in_query %}
                sub_path_summary
             {% else %}
                ${path_counts.SQL_TABLE_NAME}
             {% endif %}
        WHERE {% if us_path_analyzer.last_event_selector._in_query or us_path_analyzer.first_event_selector._in_query %}
                TRUE
              {% else %}
                country = 'US'
              {% endif %}
  ;;
  }
  
  dimension: country {
    type: string
    sql: 'US' ;;
    description: "Country of the user"
  }
}