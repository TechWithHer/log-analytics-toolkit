# Base Python image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy log generator and main scripts
COPY LOG_GENERATOR/generator.py ./LOG_GENERATOR/generator.py
COPY main.sh ./main.sh
COPY config.cfg ./config.cfg

# Create directories for logs and reports
RUN mkdir -p /app/LOG_GENERATOR /app/reports

# Install any Python packages if needed (none right now)
# RUN pip install ...

# Make main.sh executable
RUN chmod +x main.sh

# Run a script that starts generator.py in background
# and then runs main.sh in a loop
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh

# Start container
ENTRYPOINT ["./entrypoint.sh"]