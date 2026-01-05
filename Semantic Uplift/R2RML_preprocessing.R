rm(list=ls()) 
library(dplyr)
library(magrittr)
library(tidyr)
setwd("/home/michelangelo/Documenti/LAVORO_MEYER/FAIRVASC/Italian_Registry_R2RML_mappings")
FVitaly <- bigjimmy
FVitaly$closest_to_diagnosis <- rep("", nrow(FVitaly))
FVitaly$redcap_repeat_instrument[FVitaly$redcap_repeat_instrument == ""] <- "main"

for (i in 1:n_distinct(FVitaly$record_id)) {
  particularID <- subset(FVitaly, record_id==i, c(record_id, followup_date, date_of_diagnosis))
  particularID <- particularID[!apply(particularID == "", 1, all),]
  dateOfDiagnosis <- particularID$date_of_diagnosis[particularID$date_of_diagnosis!=""] %>% as.Date()
  followUps <- particularID$followup_date[particularID$followup_date!=""] %>% as.Date()
  print(particularID)
  if (length(dateOfDiagnosis)>0 & length(followUps)>0) {
    diagVisitDate <- integer(length=length(followUps))
    class(diagVisitDate) <- "Date"
    for (j in 1:length(followUps)) {
      if (followUps[j] %in% seq(dateOfDiagnosis-60, dateOfDiagnosis+60, by="day")) {
        diagVisitDate[j] <- followUps[j]
      } else {diagVisitDate[j] <- ""}
    }
    diagVisitDate <- diagVisitDate[!is.na(diagVisitDate)]
    print(diagVisitDate)
    if (length(diagVisitDate)>1) {
      timeDiff <- as.numeric(diagVisitDate-dateOfDiagnosis)
      diagVisitDate <- diagVisitDate[timeDiff==min(timeDiff,na.rm=TRUE)]
    }
    print(diagVisitDate)
    print(which(FVitaly$followup_date==diagVisitDate & FVitaly$record_id==i))
    FVitaly$closest_to_diagnosis[which(FVitaly$followup_date==diagVisitDate & FVitaly$record_id==i)] <- as.character(diagVisitDate)
    FVitaly$closest_to_diagnosis[which(FVitaly$followup_date==diagVisitDate & FVitaly$record_id==i)] %>% print()
  }
}

AAV_IDs <- subset(FVitaly, redcap_repeat_instrument=="main" & small_vessel_vas_anca %in% c(727,900,183,156152))$record_id
AAVsOnlySubset <- FVitaly[FVitaly$record_id %in% AAV_IDs,]

setwd('~/Desktop/FAIRVASC_EULAR_grant_WP2/')
write.csv(AAVsOnlySubset, file="FAIRVASC_DATA_Italian_preprocessed.csv", row.names=FALSE, na="")




