FROM python:3.12-slim

# working directory
WORKDIR /app

# instala as dependencias
COPY requirements.txt .
RUN pip install -r requirements.txt

# copia para o container
COPY . .

# port
EXPOSE 8000

# comando para rodar fastapi com uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]