FROM ubuntu
LABEL creator="tuwenyoung" email="tuwenyoung@gmail.com" \
    version="1.0" description="image for s2geometry https://github.com/google/s2geometry/"

RUN apt update -y \
    && apt-get upgrade -y \
    && apt install build-essential gcc g++ make cmake libssl-dev libffi-dev \
        libgflags-dev libgoogle-glog-dev libgtest-dev libssl-dev swig \
        python3 python3-dev python3-distutils python3-pip git swig -y

ENV BUILDDIR /app
ENV WORKDIR /app/jupyter
ENV JUYPTER /root/.jupyter/

RUN mkdir -p ${WORKDIR} \
    && mkdir -p ${JUYPTER} \
    && cd $BUILDDIR \
    && git clone https://github.com/google/s2geometry.git \
    && mkdir ${BUILDDIR}/s2geometry/build \
    && cd ${BUILDDIR}/s2geometry/build

WORKDIR ${BUILDDIR}/s2geometry/build

RUN cmake -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
        -DPYTHON_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
        -DPYTHON_EXECUTABLE:FILEPATH=`which python3` .. \
    && sed -i 's/CMAKE_INSTALL_PREFIX:PATH=\/usr\/local/CMAKE_INSTALL_PREFIX:PATH=\/usr/g' ${BUILDDIR}/s2geometry/build/CMakeCache.txt \
    && make && make install && rm -rf ${BUILDDIR}/s2geometry

RUN pip3 install jupyter folium mapboxgl pandas 
COPY ./conf/* ${JUYPTER} 
COPY ./jupyter/* ${WORKDIR}

WORKDIR ${WORKDIR}

EXPOSE 9999






