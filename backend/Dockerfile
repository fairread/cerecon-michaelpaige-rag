FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for some python packages if needed
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first for caching
COPY requirements.txt .
COPY requirements-azure.txt .

# Install all dependencies for the cloud demo
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r requirements-azure.txt

# Copy the rest of the backend code
COPY . .

# Expose the API port
EXPOSE 8000

# Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
