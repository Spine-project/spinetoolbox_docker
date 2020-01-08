# spinetoolbox_docker

This repository contains files for building a Docker image including Spine Toolbox and Spine Model.

To build the image use

    $ docker build -t spinetoolbox:latest .
    
To run the image use

    $ docker run spinetoolbox
    
You might need to set up the `DISPLAY` variable

    $ docker run -e DISPLAY=<your ip address here> spinetoolbox
    
To see a local path mounted in the container use

    $ docker run -v /local/path/:/mnt/path/ spinetoolbox
    
