view: base_exploded_paths {
  extension: required
  
  dimension: event_rank {
    type: number
    sql: ${TABLE}.event_rank ;;
    description: "Position of the event in the path"
  }

  dimension: event_table_name {
    sql: ${TABLE}.event_table_name ;;
    description: "Individual event name"
  }

  dimension: path {
    sql: ${TABLE}.path ;;
    description: "Complete path string"
  }

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.path || ${TABLE}.event_rank ;;
    description: "Unique identifier for the exploded path"
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "Country of the user"
  }
}