connection: "heap_demo_date"

# Include datagroups
include: "/models/datagroups.lkml"

# Include all view files
include: "/views/base/*.view.lkml"
include: "/views/intermediate/*.view.lkml"
include: "/views/paths/*.view.lkml"
include: "/views/analysis/*.view.lkml"

# Main explore for path analysis
explore: path_analyzer {
  label: "User Journey Analysis"
  description: "Analyze user paths through your application"
  
  join: exploded_paths {
    type: left_outer
    relationship: one_to_many
    sql_on: ${path_analyzer.path} = ${exploded_paths.path} ;;
  }
  
  join: path_counts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${path_analyzer.path} = ${path_counts.path} ;;
  }
  
  join: session_paths {
    type: left_outer
    relationship: many_to_one
    sql_on: ${exploded_paths.path} = ${session_paths.path} ;;
  }
}

# Supporting explores
explore: event_counts {
  label: "Event Popularity"
  description: "Analyze frequency of individual events"
  hidden: yes  # Used for suggestions only
}

# Funnel Analysis explore
explore: funnel_analysis {
  from: path_analyzer
  label: "Conversion Funnel Analysis"
  description: "Analyze conversion rates between key events"
  
  join: exploded_paths {
    type: left_outer
    relationship: one_to_many
    sql_on: ${funnel_analysis.path} = ${exploded_paths.path} ;;
  }
}