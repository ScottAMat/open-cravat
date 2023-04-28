FROM python:3.8

ARG PACKAGEDIR=/usr/local/lib/python3.8/site-packages/cravat
ARG BRANCH=master

RUN apt update && apt install -y vim sqlite3
RUN git clone https://github.com/ScottAMat/open-cravat.git --single-branch --branch $BRANCH && \
    pip install ./open-cravat && \
    pip install open-cravat-multiuser aiosqlite3 scipy pytabix

# This is a test build
# Needed for gds-converter module
# Install latest R, folllowing docs at https://cloud.r-project.org/bin/linux/debian/
RUN apt install -y --no-install-recommends software-properties-common dirmngr && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    apt update && apt install -y r-base && \
    pip install rpy2
# Install R packages
RUN R -e 'install.packages("BiocManager"); BiocManager::install("SeqArray");'

# Run oc version first to create some directories
RUN oc version && \
    mv $PACKAGEDIR/conf /mnt/conf && ln -s /mnt/conf $PACKAGEDIR/conf && \
    mv $PACKAGEDIR/modules /mnt/modules && ln -s /mnt/modules $PACKAGEDIR/modules && \
    mv $PACKAGEDIR/jobs /mnt/jobs && ln -s /mnt/jobs $PACKAGEDIR/jobs && \
    mv $PACKAGEDIR/logs /mnt/logs && ln -s /mnt/logs $PACKAGEDIR/logs
VOLUME /mnt/conf
VOLUME /mnt/modules
VOLUME /mnt/jobs
VOLUME /mnt/logs

VOLUME /tmp/job
WORKDIR /tmp/job
