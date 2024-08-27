FROM continuumio/miniconda3

# Copy the environment.yml file
COPY environment.yml /environment.yml

# Set the LC_ALL environment variable
ENV LC_ALL C

# Create the conda environment
RUN conda env create -f /environment.yml

# Define the default command to run within the container
CMD ["/opt/conda/envs/$(head -n 1 environment.yml | cut -f 2 -d ' ')/bin/bash"]