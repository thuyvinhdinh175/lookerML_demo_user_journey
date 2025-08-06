connection: "heap_demo_date"

# Include datagroups
include: "/models/datagroups.lkml"

# Include all view files
include: "/views/base/*.view.lkml"
include: "/views/intermediate/*.view.lkml"
include: "/views/paths/*.view.lkml"
include: "/views/analysis/*.view.lkml"

# Base explore for path analysis
explore: base_path_analyzer {
  extension: required
  
  join: global_exploded_paths {
    type: left_outer
    relationship: one_to_many
    sql_on: ${base_path_analyzer.path} = ${global_exploded_paths.path} ;;
  }
  
  join: path_counts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${base_path_analyzer.path} = ${path_counts.path} ;;
  }
  
  join: global_session_paths {
    type: left_outer
    relationship: many_to_one
    sql_on: ${global_exploded_paths.path} = ${global_session_paths.path} ;;
  }
}

# Global explore
explore: global_path_analyzer {
  extends: [base_path_analyzer]
  label: "Global User Journey Analysis"
  description: "Analyze user paths through your application - Global"
}

# US explore
explore: us_path_analyzer {
  extends: [base_path_analyzer]
  label: "US User Journey Analysis"
  description: "Analyze user paths through your application - US"
  
  join: us_exploded_paths {
    from: us_exploded_paths
    type: left_outer
    relationship: one_to_many
    sql_on: ${us_path_analyzer.path} = ${us_exploded_paths.path} ;;
  }
  
  join: us_session_paths {
    from: us_session_paths
    type: left_outer
    relationship: many_to_one
    sql_on: ${us_exploded_paths.path} = ${us_session_paths.path} ;;
  }
}

# UK explore
explore: uk_path_analyzer {
  extends: [base_path_analyzer]
  label: "UK User Journey Analysis"
  description: "Analyze user paths through your application - UK"
  
  join: uk_exploded_paths {
    from: uk_exploded_paths
    type: left_outer
    relationship: one_to_many
    sql_on: ${uk_path_analyzer.path} = ${uk_exploded_paths.path} ;;
  }
  
  join: uk_session_paths {
    from: uk_session_paths
    type: left_outer
    relationship: many_to_one
    sql_on: ${uk_exploded_paths.path} = ${uk_session_paths.path} ;;
  }
}

# Base funnel analysis explore
explore: base_funnel_analysis {
  extension: required
  
  join: global_exploded_paths {
    type: left_outer
    relationship: one_to_many
    sql_on: ${base_funnel_analysis.path} = ${global_exploded_paths.path} ;;
  }
}

# Global funnel analysis
explore: global_funnel_analysis {
  extends: [base_funnel_analysis]
  from: global_path_analyzer
  label: "Global Conversion Funnel Analysis"
  description: "Analyze conversion rates between key events - Global"
}

# US funnel analysis
explore: us_funnel_analysis {
  extends: [base_funnel_analysis]
  from: us_path_analyzer
  label: "US Conversion Funnel Analysis"
  description: "Analyze conversion rates between key events - US"
  
  join: us_exploded_paths {
    from: us_exploded_paths
    type: left_outer
    relationship: one_to_many
    sql_on: ${us_funnel_analysis.path} = ${us_exploded_paths.path} ;;
  }
}

# UK funnel analysis
explore: uk_funnel_analysis {
  extends: [base_funnel_analysis]
  from: uk_path_analyzer
  label: "UK Conversion Funnel Analysis"
  description: "Analyze conversion rates between key events - UK"
  
  join: uk_exploded_paths {
    from: uk_exploded_paths
    type: left_outer
    relationship: one_to_many
    sql_on: ${uk_funnel_analysis.path} = ${uk_exploded_paths.path} ;;
  }
}

# Supporting explores
explore: event_counts {
  label: "Event Popularity"
  description: "Analyze frequency of individual events"
  hidden: yes  # Used for suggestions only
}