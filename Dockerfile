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
RUN pip install git+https://github.com/Spine-project/Spine-Database-API.git#egg=spinedb_api
RUN pip install git+https://github.com/Spine-project/spine-engine.git#egg=spine_engine

# Install Toolbox incl. prerequisities
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y libpq-dev
RUN pip install python-dateutil==2.8.0
RUN pip install ipykernel
RUN python -m ipykernel install --name python-$(python -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))")
RUN julia -e "using Pkg; Pkg.add(\"IJulia\")"
RUN pip install git+https://github.com/Spine-project/Spine-Toolbox.git#egg=spinetoolbox

# Install Spine Model
RUN PYTHON=$(which python) julia -e "using Pkg; Pkg.add(PackageSpec(url=\"https://github.com/Spine-project/SpineInterface.jl.git\"))"
RUN julia -e "using Pkg; Pkg.add(PackageSpec(url=\"https://github.com/Spine-project/Spine-Model.git\"))"
RUN julia -e "using Pkg; Pkg.precompile()"

# Clean up
RUN apt-get remove -y build-essential
RUN apt-get remove -y wget
RUN apt-get remove -y git
RUN apt-get autoremove -y
RUN apt-get clean -y

# Run Spine Toolbox
CMD ["spinetoolbox"]
