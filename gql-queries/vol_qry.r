


# Task 4b - GQL for volumes
#vol_qry = function(id, from, to) {
#  query = paste0('{ volumeData(id: "', id, '", from: "', from, '", to: "', to, '") { id dateTime ... } }')
#  return(query)
#}


vol_qry <- function(id, from, to) {
  # Construct the GraphQL query using sprintf for string formatting
  query <- sprintf(
    '{
      trafficData(trafficRegistrationPointId: "%s") {
        volume {
          byHour(from: "%s", to: "%s") {
            edges {
              node {
                from
                to
                total {
                  volumeNumbers {
                    volume
                  }
                }
              }
            }
          }
        }
      }
    }', id, from, to)
  
  return(query)
}

