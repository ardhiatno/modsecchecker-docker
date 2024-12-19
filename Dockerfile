FROM python:3.9-slim-bullseye AS modsecurity

RUN apt update && apt-get install -y make wget g++ flex bison curl doxygen libyajl-dev libgeoip-dev libtool dh-autoreconf libcurl4-gnutls-dev libxml2 libxml2-dev libpcre3-dev git cmake python3-dev
RUN wget https://github.com/SpiderLabs/ModSecurity/releases/download/v3.0.4/modsecurity-v3.0.4.tar.gz
RUN tar xvf modsecurity-v3.0.4.tar.gz && cd modsecurity-v3.0.4 && ./build.sh && ./configure && make && make install
RUN cd / ; rm -Rf modsecurity-v3.0.4*
RUN pip install wheel setuptools pybind11 pip --upgrade
RUN git clone --recurse-submodules https://github.com/pymodsecurity/pymodsecurity.git
RUN git clone https://github.com/migolovanov/modsecurity-checker.git
RUN git clone https://github.com/coreruleset/coreruleset.git
RUN cd pymodsecurity && mkdir build && cd build && cmake .. -DMODSEC_PATH="/usr/local/modsecurity" -DMODSEC_LIBRARY="/usr/local/modsecurity/lib/libmodsecurity.so" && make


FROM python:3.9-slim-bullseye
RUN mkdir -p /usr/local/lib/python3.9/site-packages/ && mkdir -p /usr/lib/x86_64-linux-gnu
COPY --from=modsecurity /pymodsecurity/build/ModSecurity.cpython-39-x86_64-linux-gnu.so /usr/local/lib/python3.9/site-packages/ModSecurity.so
COPY requirements.txt .
COPY --from=modsecurity modsecurity-checker .
COPY --from=modsecurity /usr/local/modsecurity /usr/local/modsecurity
COPY --from=modsecurity /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=modsecurity /coreruleset/rules /owasp-modsecurity-crs
RUN pip install --no-cache-dir -r requirements.txt