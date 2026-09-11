FROM julia:1.12.7

RUN apt-get update && apt-get install -y git

WORKDIR /app

ENV JULIA_CI true
ENV JULIA_NUM_THREADS "auto"

COPY webapi /app/webapi
COPY core /app/core

WORKDIR /app/core
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"

WORKDIR /app/webapi
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"

CMD ["julia", "--project=.", "src/server.jl"]
