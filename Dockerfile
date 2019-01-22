#docker build -t eli88fine/opentrons-ot2-simulation .

#docker run -it --rm eli88fine/opentrons-ot2-simulation bash

# docker push eli88fine/opentrons-ot2-simulation


FROM python:3.6.8-alpine3.8


# Upgrade pip, in case the latest alpine base image does not have the most up-to-date version
RUN python -m pip install --no-cache-dir --upgrade pip;


# install basic apps: bash and git
#  ######### make and yarn are needed specifically for the opentrons api
#  #########  ... npm seemed to be needed for running 'make' on the opentrons api
RUN apk update && apk upgrade && \
    apk add --no-cache bash git make yarn npm




# clone the opentrons repository and set to defined commit
RUN git clone https://github.com/Opentrons/opentrons.git && \
    cd opentrons && \
    git reset --hard 28b957346309a3b597f8bece6cebe1115a6ade34;


# build the opentrons api
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    && cd opentrons \
    && make \
    && cd .. \
    && apk del .build-deps    

# make sure it's at a defined commit. 28b957346309a3b597f8bece6cebe1115a6ade34


# for whatever reason, combining the 'make wheel' with the 'pip install' layer causes issues
RUN cd opentrons/api \
    && make wheel \    
    && cd .. \
    && cd ..



# install the opentrons API so that 'make local-shell' does not have to be run each time.   the link to xlocale.h is needed for numpy...for some reason it was not working before. https://serverfault.com/questions/771211/docker-alpine-and-matplotlib
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \
    && cd opentrons/api \
    && pip install --no-cache-dir dist/opentrons-*.whl \
    && cd .. \
    && cd .. \
    && apk del .build-deps 



#RUN cd opentrons/api \
#    && make local-shell \    
#    && cd .. \
#    && cd ..

# install the opentrons API so that 'make local-shell' does not have to be run each time
#RUN apk add --no-cache --virtual .build-deps \
#    gcc \
#    musl-dev \
#    libffi-dev \
#    openssl-dev \
#    && pip install --no-cache-dir opentrons/api/dist/opentrons-*.whl \
#    && apk del .build-deps    


# Because repository names can sometimes conflict with root directory names (i.e. 'media'), create a 'source' subdirectory and clone all code into that
#RUN mkdir source
#WORKDIR source






#COPY ../source source/


#COPY . .

#CMD [ "python", "./hello_world.py" ]

##### previously it used $PWD instead, but that didn't seem to be working
# to run a single script: docker run -it --rm --name my-running-script -v `pwd`:/usr/src/myapp -w /usr/src/myapp python:3 python hello_world.py

#### NOTE, docker-toolbox must be used within a subdirectory of C:\Users in order to mount volumes
#### NOTE, in order to be able to write to hard drive, open Virtual Box, click Settings, Shared Folders, Add C:\Users\gitRepos\football_scraping as usr/src/football_scraping, with Auto-mount and Make Permanent checked


### If VirtualBox is started in administrative mode and then the machine inside there is used and a volume is mounted to the container, then it seems to work. but copy/paste isn't working inside the VirtualBox



### 6/2/18: Start VirtualBox in adimnistrator mode, start docker quickstart in administrator mode, use this: docker run -it --rm --name my-running-script -v /c/Users/gitRepos/football_scraping/output:/mnt -w /football_scraping eli88fine/football_scraping:historical-data-scraper bash
########## may not need to start virtual box in administrator mode, just the docker quickstart
### to run single script: docker run -it --rm --name my-running-script -v /c/Users/gitRepos/football_scraping/output:/mnt -w /football_scraping/source eli88fine/football_scraping:historical-data-scraper python hello_world.py
### to run single script that is outisde container: docker run -it --rm --name my-running-script -v /c/Users/gitRepos/football_scraping/output:/mnt -v /c/Users/gitRepos/football_scraping/source:/football_scraping/source -w /football_scraping/source eli88fine/football_scraping:historical-data-scraper python hello_world.py


# to upload:
# 
# docker login     (if not already logged in during this session)
# docker push eli88fine/football_scraping:historical-data-scraper