# Get julia image
FROM julia:latest AS julia

# Get Python 
FROM bildcode/pyside2:latest

# Update package repository and install some required libraries
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y git

# Copy Julia
ARG jl_path=/usr/local/julia
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
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y libpq-dev
RUN pip install python-dateutil==2.8.0
RUN pip install ipykernel
RUN python -m ipykernel install --name python-$(python -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))")
RUN julia -e "using Pkg; Pkg.add(\"IJulia\")"
COPY ./toolbox /Spine-Toolbox
RUN pip install /Spine-Toolbox

# Install Spine Model
COPY ./model /Spine-Model
COPY ./SpineInterface.jl /SpineInterface.jl
RUN PYTHON=$(which python) julia -e "using Pkg; Pkg.develop(PackageSpec(path=\"/SpineInterface.jl\"))"
RUN julia -e "using Pkg; Pkg.develop(PackageSpec(path=\"/Spine-Model\"))"
RUN julia -e "using Pkg; Pkg.precompile()"

# Clean up
RUN apt-get remove -y build-essential
RUN apt-get remove -y wget
RUN apt-get remove -y git
RUN apt-get autoremove -y
RUN apt-get clean -y

# Run Spine Toolbox
CMD ["spinetoolbox"]
