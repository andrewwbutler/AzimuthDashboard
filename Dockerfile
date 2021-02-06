FROM rocker/r-ver:4.0.3

# Install system dependencies                                                              
RUN apt-get update                                                                                  
RUN apt-get install -y \  
    libcurl4-openssl-dev \ 
    libssl-dev

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=FALSE

RUN R --no-echo -e "install.packages(c('cowplot', 'dplyr', 'ggplot2', 'googlesheets4', 'shiny', 'shinydashboard', 'withr'))"

COPY . /root/AzimuthDashboard
RUN R --no-echo -e "install.packages('/root/AzimuthDashboard', repos = NULL, type = 'source')"
COPY Rprofile.site /usr/local/lib/R/etc/Rprofile.site

EXPOSE 3838

CMD ["R", "-e", "AzimuthDashboard::AzimuthDashboardApp(config='/config')"]
