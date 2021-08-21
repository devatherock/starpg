FROM alpine

LABEL maintainer="devatherock@gmail.com"

COPY release/starpg /bin/starpg

COPY editor/ /editor/

CMD ["/bin/starpg"]