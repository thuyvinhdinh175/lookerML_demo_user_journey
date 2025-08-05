# Datagroups for coordinated refreshes
datagroup: daily_refresh {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

datagroup: hourly_refresh {
  sql_trigger: SELECT FLOOR(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP()) / 3600) ;;
  max_cache_age: "1 hour"
}

datagroup: weekly_refresh {
  sql_trigger: SELECT EXTRACT(WEEK FROM CURRENT_DATE()) ;;
  max_cache_age: "168 hours"
}