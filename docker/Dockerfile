FROM python:3.9-slim-buster

WORKDIR /app

# Copy the current directory into the container at /app
COPY . /app

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run the python main.py script with the -u flag
CMD ["python", "-u", "main.py"]
