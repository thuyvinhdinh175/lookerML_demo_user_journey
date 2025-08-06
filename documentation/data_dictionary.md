# LookML User Journey Path Analysis - Data Dictionary

## Overview

This data dictionary provides definitions for all dimensions, measures, and parameters used in the User Journey Path Analysis framework. Use this as a reference when working with the model.

## Base Templates

### base_events

| Field | Type | Description |
|-------|------|-------------|
| user_id | Dimension | Unique identifier for the user |
| session_id | Dimension | Unique identifier for the session |
| event_id | Dimension | Unique identifier for the event (Primary Key) |
| event_table_name | Dimension | Name of the event |
| event_time | Dimension Group | When the event occurred |
| event_date | Dimension | Date of the event (for incremental processing) |
| event_hour | Dimension | Hour of the event (for time-based analysis) |
| country | Dimension | Country of the user |

### base_unique_events

| Field | Type | Description |
|-------|------|-------------|
| user_id | Dimension | Unique identifier for the user |
| session_id | Dimension | Unique identifier for the session |
| event_id | Dimension | Unique identifier for the event (Primary Key) |
| event_table_name | Dimension | Name of the event |
| event_rank | Dimension | Sequential rank of the event within the session |
| event_time | Dimension Group | When the event occurred |
| event_date | Dimension | Date of the event (for incremental processing) |
| country | Dimension | Country of the user |

### base_session_paths

| Field | Type | Description |
|-------|------|-------------|
| user_id | Dimension | Unique identifier for the user |
| session_id | Dimension | Unique identifier for the session |
| path | Dimension | Complete path of events in the session |
| path_length | Dimension | Number of events in the path |
| first_event_time | Dimension Group | When the first event in the path occurred |
| last_event_time | Dimension Group | When the last event in the path occurred |
| session_duration | Dimension | Duration of the session in seconds |
| average_session_duration | Measure | Average duration of sessions in seconds |
| count | Measure | Count of unique session paths |
| average_path_length | Measure | Average number of events in paths |
| country | Dimension | Country of the user |

### base_exploded_paths

| Field | Type | Description |
|-------|------|-------------|
| path | Dimension | Complete path string |
| event_table_name | Dimension | Individual event name |
| event_rank | Dimension | Position of the event in the path |
| country | Dimension | Country of the user |

### base_path_analyzer

| Field | Type | Description |
|-------|------|-------------|
| first_event_selector | Filter | The name of the event starting the path you would like to analyze |
| last_event_selector | Filter | The name of the event ending the path you would like to analyze |
| path | Dimension | Complete path string (Primary Key) |
| step_1 through step_7 | Dimensions | Individual events in the path sequence |
| total_sessions | Measure | Total sessions with this path |

## Data Source Layer

### global_events, us_events, uk_events

These views extend base_events and provide country-specific event data.

## Processing Layer

### global_unique_events, us_unique_events, uk_unique_events

These views extend base_unique_events and provide country-specific unique event data.

### event_counts

| Field | Type | Description |
|-------|------|-------------|
| event_table_name | Dimension | Name of the event |
| count | Measure | Number of occurrences of the event |

### event_string_length

| Field | Type | Description |
|-------|------|-------------|
| user_id | Dimension | Unique identifier for the user |
| session_id | Dimension | Unique identifier for the session |
| event_rank | Dimension | Sequential rank of the event within the session |
| cumulative_characters | Dimension | Running total of characters in the path string |

## Path Construction Layer

### global_session_paths, us_session_paths, uk_session_paths

These views extend base_session_paths and provide country-specific session path data.

### example_paths

| Field | Type | Description |
|-------|------|-------------|
| path | Dimension | Unique path string |
| user_id | Dimension | Example user with this path |
| session_id | Dimension | Example session with this path |

### global_exploded_paths, us_exploded_paths, uk_exploded_paths

These views extend base_exploded_paths and provide country-specific exploded path data.

## Analysis Layer

### global_path_analyzer, us_path_analyzer, uk_path_analyzer

These views extend base_path_analyzer and provide country-specific path analysis tools.

| Field | Type | Description |
|-------|------|-------------|
| country | Dimension | Country of the user |

### path_counts

| Field | Type | Description |
|-------|------|-------------|
| path | Dimension | Complete path string (Primary Key) |
| count | Dimension | Number of sessions with this path |

### funnel_analysis

| Field | Type | Description |
|-------|------|-------------|
| funnel_step1 through funnel_step4 | Filters | Events to include in each step of the funnel |
| path | Dimension | Complete path string |
| user_id | Dimension | Unique identifier for the user |
| session_id | Dimension | Unique identifier for the session |
| first_event_date | Dimension Group | Date of the first event in the path |
| step1_event through step4_event | Dimensions | Events at each step in the funnel |
| converted_to_step2 through converted_to_step4 | Dimensions | Whether the path converted to each step |
| count_paths | Measure | Count of unique paths |
| count_step1 through count_step4 | Measures | Count of paths with each step |
| step1_to_step2_conversion_rate through step3_to_step4_conversion_rate | Measures | Conversion rates between sequential steps |
| overall_conversion_rate | Measure | Overall conversion rate from step 1 to step 4 |

## Parameters and Filters

| Parameter | Type | Description |
|-----------|------|-------------|
| first_event_selector | Filter | The name of the event starting the path you would like to analyze |
| last_event_selector | Filter | The name of the event ending the path you would like to analyze |
| funnel_step1 through funnel_step4 | Filters | Events to include in each step of the funnel |
| date_range | Filter | Date range for filtering path data |

## Datagroups

| Datagroup | Trigger | Max Cache Age | Description |
|-----------|---------|---------------|-------------|
| daily_refresh | CURRENT_DATE() | 24 hours | Refreshes data once per day |
| hourly_refresh | FLOOR(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP()) / 3600) | 1 hour | Refreshes data once per hour |
| weekly_refresh | EXTRACT(WEEK FROM CURRENT_DATE()) | 168 hours | Refreshes data once per week |