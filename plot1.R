require(downloader)
dataFile <- "household_power_consumption"

#This section does work that is time consuming and only needs to be done once.  
#  If the smaller file exists, this is skipped, otherwise this routine:
#  downloads the zip file
#  unzips it
#  reads it in
#  removes all but the required dates
#  formates the date/time variables correctly and puts them as 1st column in dataset
#  writes a sub-set data file
if (! file.exists(paste(dataFile, ".csv", sep=""))) {
        fileURL <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
        download(fileURL, paste(dataFile, ".zip", sep=""), mode="wb")
        unzip(paste(dataFile, ".zip", sep=""))
        
        allData <- read.csv(paste(dataFile, ".txt", sep=""), sep=';', header=TRUE)
        allData$Date <- as.Date(allData$Date, format="%d/%m/%Y")
        subData <- subset(allData, subset = (Date >= "2007-02-01" & Date <= "2007-02-02"))
        DT <- paste(as.Date(subData$Date), subData$Time)
        subData$DateTime <- as.POSIXct(DT)
        drops <- c("Date","Time")
        subData <- subData[,!(names(subData) %in% drops)]
        
        col_idx <- grep("DateTime", names(subData))
        subData <- subData[, c(col_idx, (1:ncol(subData))[-col_idx])]
        
        #make rest of the columns numbers
        subData$Global_active_power <- as.numeric(as.character(subData$Global_active_power))
        subData$Global_reactive_power <- as.numeric(as.character(subData$Global_reactive_power))
        subData$Voltage <- as.numeric(as.character(subData$Voltage))
        subData$Global_intensity <- as.numeric(as.character(subData$Global_intensity))
        subData$Sub_metering_1 <- as.numeric(as.character(subData$Sub_metering_1))
        subData$Sub_metering_2 <- as.numeric(as.character(subData$Sub_metering_2))
        subData$Sub_metering_3 <- as.numeric(as.character(subData$Sub_metering_3))
        
        write.csv(subData, file=paste(dataFile, ".csv", sep=""), row.names=FALSE)
        
        #clean up files, save memory
        file.remove(paste(dataFile, ".zip", sep=""))
        file.remove(paste(dataFile, ".txt", sep=""))
        rm(allData)
        rm(subData)
        rm(DT)
        rm(col_idx)
        rm(drops)
        rm(fileURL)
}

#read in only required data
subData <- read.csv(paste(dataFile, ".csv", sep=""))
subData$DateTime <- as.POSIXct(subData$DateTime)

#create the device
png(filename="plot1.png", width=480, height=480)
hist(subData$Global_active_power, col = "red", main = "Global Active Power", xlab = "Global Active Power (kilowatts)")

#close the device
dev.off()
