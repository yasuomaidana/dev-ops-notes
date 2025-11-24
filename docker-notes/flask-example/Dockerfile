FROM python:3.13.5-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY . /app


WORKDIR /app

# RUN uv sync --locked  -> pip install -r requirements.txt
RUN uv add flask art
ENV Name="Bobtron"

EXPOSE 8080
ENTRYPOINT ["uv", "run", "main.py"]

