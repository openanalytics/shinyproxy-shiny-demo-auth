FROM openanalytics/r-ver:4.3.3

RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/latest
RUN echo "\noptions(shiny.port=3838, shiny.host='0.0.0.0')" >> /usr/local/lib/R/etc/Rprofile.site

# system libraries of general use
RUN apt-get update && apt-get install --no-install-recommends -y \
    pandoc \
    pandoc-citeproc \
    libcairo2-dev \
    libxt-dev \
    && rm -rf /var/lib/apt/lists/*

# basic shiny functionality
RUN R -q -e "options(warn=2); install.packages(c('shiny'))"

# install R code
COPY example /app
WORKDIR /app

EXPOSE 3838

# create user
RUN groupadd -g 1000 shiny && useradd -c 'shiny' -u 1000 -g 1000 -m -d /home/shiny -s /sbin/nologin shiny
USER shiny

CMD ["R", "-q", "-e", "shiny::runApp('/app')"]
