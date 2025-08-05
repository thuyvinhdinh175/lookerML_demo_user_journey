# LookML User Journey Path Analysis - Implementation Guide

## Overview

This implementation guide provides detailed instructions for setting up and customizing the User Journey Path Analysis framework in your Looker instance. The framework is designed to analyze how users navigate through your application by tracking event sequences and creating path analyses.

## Setup Process

### 1. Database Requirements

Ensure your database contains event data with the following fields:
- `user_id`: Unique identifier for the user
- `session_id`: Unique identifier for the session
- `event_id`: Unique identifier for the event
- `event_table_name`: Name of the event
- `time`: Timestamp when the event occurred

### 2. Connection Setup

1. Create a connection to your database in Looker
2. Update the connection name in `models/journeys.model.lkml`:
   ```lookml
   connection: "your_connection_name"
   ```

### 3. Base Table Configuration

Modify the `views/base/base_all_events.view.lkml` file to match your event table structure:

```lookml
view: base_all_events {
  derived_table: {
    datagroup_trigger: daily_refresh
    
    sql: (
      SELECT 
        *,
        DATE(time) as event_date,
        EXTRACT(HOUR FROM time) as event_hour
      FROM your_schema.your_events_table
      WHERE time > CURRENT_DATE - INTERVAL '90 days'
    ) ;;
  }
  
  # Dimensions...
}
```

### 4. Datagroup Configuration

Adjust the refresh schedules in `models/datagroups.lkml` to match your requirements:

```lookml
datagroup: daily_refresh {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

datagroup: hourly_refresh {
  sql_trigger: SELECT FLOOR(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP()) / 3600) ;;
  max_cache_age: "1 hour"
}
```

### 5. SQL Dialect Adjustments

Depending on your database (BigQuery, Redshift, Snowflake), you may need to adjust SQL syntax:

#### BigQuery
- Use `STRING_AGG` instead of `LISTAGG`
- Use `TIMESTAMP_DIFF` instead of `DATEDIFF`

#### Redshift
- Use `LISTAGG` as shown in the examples
- Use `DATEDIFF` as shown in the examples

#### Snowflake
- Use `LISTAGG` as shown in the examples
- Use `DATEDIFF` as shown in the examples

## Performance Optimization

### Incremental PDT Configuration

For large tables, incremental PDTs are used to avoid full rebuilds:

```lookml
derived_table: {
  increment_key: "event_date"
  increment_offset: 3  # Days of overlap
  datagroup_trigger: daily_refresh
  materialized: yes
  
  sql: 
    {% if _incremental %}
      -- Incremental update logic
      -- Query only recent data
    {% else %}
      -- Initial full build
      -- Query all data
    {% endif %}
  ;;
}
```

### Materialized View Configuration

For frequently queried tables, materialized views improve performance:

```lookml
derived_table: {
  materialized: yes
  datagroup_trigger: daily_refresh
  indexes: ["user_id", "session_id"]
  distribution: "user_id"
  
  sql: -- Your SQL query ;;
}
```

## Customization Options

### Adding Custom Events

To add custom events to your analysis:
1. Ensure the events are included in your base event table
2. The framework will automatically include them in path analysis

### Extending the Funnel Analysis

To customize the funnel analysis:
1. Modify the `views/analysis/funnel_analysis.view.lkml` file
2. Add additional steps or custom conversion metrics

### Creating Custom Dashboards

To create custom dashboards:
1. Use the provided `dashboards/path_analysis.dashboard.lookml` as a template
2. Add or modify elements to meet your specific requirements

## Troubleshooting

### Common Issues

1. **Path String Overflow**
   - Symptom: Missing paths or SQL errors
   - Solution: The `event_string_length` view prevents this by limiting path length to 65,535 characters

2. **Slow Performance**
   - Symptom: Slow query execution
   - Solution: Check materialization settings, adjust datagroup refresh schedules, or optimize SQL

3. **Missing Events**
   - Symptom: Events not appearing in paths
   - Solution: Verify events exist in the base table and check for filtering in the SQL

## Advanced Configuration

### Custom Path Separators

To change the path separator:
1. Modify the `LISTAGG` function in `session_paths.view.lkml`:
   ```sql
   LISTAGG(aue.event_table_name, ' → ')
   ```

2. Update the `SPLIT_PART` functions in `path_analyzer.view.lkml`:
   ```sql
   SPLIT_PART(${TABLE}.path, ' → ', 1)
   ```

### Time Between Events Analysis

To add time between events analysis:
1. Modify the `exploded_paths.view.lkml` file to include event timestamps
2. Add measures to calculate time differences between events

## Best Practices

1. **Regular Maintenance**
   - Monitor PDT build times and adjust refresh schedules as needed
   - Review path patterns periodically to identify new user behaviors

2. **Data Volume Management**
   - Consider reducing the time window for historical data if performance suffers
   - Use incremental PDTs for all large tables

3. **Documentation**
   - Document custom events and their meanings
   - Create a data dictionary for business users

4. **Testing**
   - Test with sample paths to ensure correct path construction
   - Validate conversion metrics against other analytics tools