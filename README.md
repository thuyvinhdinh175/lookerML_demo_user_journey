# LookML User Journey Path Analysis

## Overview
This project provides a powerful user journey analysis framework built with LookML. It allows you to track, analyze, and visualize how users navigate through your application or website by capturing event sequences and creating path analyses.

## Features
- **Path Analysis**: Track complete user journeys through your application
- **Event Filtering**: Filter paths by specific start and end events
- **Session Analysis**: Analyze user behavior within sessions
- **Path Visualization**: See common paths users take through your application
- **Event Counting**: Understand frequency and popularity of different events
- **Funnel Analysis**: Track conversion rates between key events
- **Performance Optimization**: Materialized views and incremental PDTs for efficient processing

## Data Model
The data model consists of several interconnected views that work together to create a comprehensive path analysis system:

1. **Base Events**: Raw event data from the database
2. **Unique Events**: Deduplicated events with sequential ranking
3. **Session Paths**: Complete paths taken by users in each session
4. **Path Analysis**: Tools to analyze specific segments of user journeys
5. **Funnel Analysis**: Conversion tracking between sequential events

## Architecture
The project follows a layered architecture:

1. **Data Source Layer**: `base_all_events` - Connects to raw event data
2. **Processing Layer**: 
   - `all_unique_events` - Deduplicates and ranks events (Incremental PDT)
   - `event_string_length` - Handles string length limitations
   - `event_counts` - Counts event occurrences
3. **Path Construction Layer**:
   - `session_paths` - Constructs complete user paths (Materialized)
   - `example_paths` - Provides example paths for analysis
   - `exploded_paths` - Breaks down paths into individual events
4. **Analysis Layer**:
   - `path_analyzer` - Provides tools for analyzing specific path segments
   - `path_counts` - Counts occurrences of specific paths
   - `funnel_analysis` - Analyzes conversion between sequential events

## Project Structure
```
lookerML_demo_user_journey/
├── models/
│   ├── journeys.model.lkml       # Contains explores and connections
│   └── datagroups.lkml          # Defines refresh schedules
├── views/
│   ├── base/                     # Base/source tables
│   ├── intermediate/             # Processing layer views
│   ├── paths/                    # Path construction layer
│   └── analysis/                 # Analysis layer
├── dashboards/                   # LookML dashboards
└── documentation/                # Documentation files
```

## Usage
1. Access the Looker instance where this project is deployed
2. Navigate to the "Path Analyzer" explore
3. Use the "First Event Selector" and "Last Event Selector" filters to analyze specific path segments
4. Visualize user journeys using the available dimensions and measures
5. Use the "Funnel Analysis" explore to analyze conversion rates

## Requirements
- Database with event data (BigQuery, Redshift, or Snowflake)
- Events must include: user_id, session_id, event_id, event_table_name, and timestamp
- Looker or LookML-compatible platform

## Implementation Notes
- The model is designed to handle large volumes of event data efficiently
- Path strings are limited to 65,535 characters to prevent overflow errors
- Events are deduplicated to ensure accurate path analysis
- Incremental PDTs are used for large tables to improve performance
- Materialized views are used for frequently queried derived tables

## Example Queries
- Find the most common paths users take through your application
- Analyze paths that start with a specific event (e.g., "Sign Up")
- Identify paths that lead to conversion events (e.g., "Purchase")
- Compare path frequencies across different time periods
- Analyze conversion rates between key funnel steps

## Performance Optimization
- **Incremental PDTs**: Used for `all_unique_events` to efficiently process large datasets
- **Materialized Views**: Used for `session_paths` and other frequently queried views
- **Datagroups**: Coordinated refresh schedules to minimize processing overhead
- **Indexes**: Added to key fields to improve query performance

## Customization
To adapt this model to your specific data:
1. Update the connection in `models/journeys.model.lkml`
2. Modify the SQL in `views/base/base_all_events.view.lkml` to match your event table structure
3. Adjust event naming and filtering as needed for your specific use case
4. Update the datagroups in `models/datagroups.lkml` to match your refresh requirements