FROM julia:1.3.0 AS julia
RUN apt-get update

FROM bildcode/pyside2:py3.7

# Update package repository and install some required libraries
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y git

# Copy Julia
ARG jl_path=/usr/local/julia
ARG jl_pkgdir=/root/.julia
COPY --from=julia ${jl_path} ${jl_path}
ENV PATH ${jl_path}/bin:$PATH
RUN julia -v

# Upgrade pip
RUN pip install --upgrade pip

# Install DB API and Engine
COPY ./data /Spine-Database-API
RUN pip install /Spine-Database-API
COPY ./engine /Spine-Engine
RUN pip install /Spine-Engine

# Install Toolbox incl. prerequisities
COPY ./toolbox /Spine-Toolbox
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y libpq-dev
RUN pip install python-dateutil==2.8.0
RUN pip install ipykernel
#RUN python -m ipykernel install --user --name python-3.7 --display-name=??
RUN julia -e "using Pkg; Pkg.add(\"IJulia\")"
RUN pip install /Spine-Toolbox

# Install Spine Model
COPY ./model /Spine-Model
COPY ./SpineInterface.jl /SpineInterface.jl
ENV PYTHON=/usr/local/bin/python
RUN julia -e "using Pkg; Pkg.develop(PackageSpec(path=\"/SpineInterface.jl\"))"
RUN julia -e "using Pkg; Pkg.develop(PackageSpec(path=\"/Spine-Model\"))"
RUN julia -e "using Pkg; Pkg.precompile()"

# Run Spine Toolbox
CMD ["spinetoolbox"]
