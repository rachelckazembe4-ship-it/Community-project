# Postgres setup

The backend now uses Postgres by default.

## Local development

Create a Postgres database named `community_project`, or set your own values with environment variables:

```powershell
$env:POSTGRES_DB="community_project"
$env:POSTGRES_USER="postgres"
$env:POSTGRES_PASSWORD="postgres"
$env:POSTGRES_HOST="localhost"
$env:POSTGRES_PORT="5432"
```

You can also set a single connection URL:

```powershell
$env:DATABASE_URL="postgres://postgres:postgres@localhost:5432/community_project"
```

Then run:

```powershell
cd backend
python manage.py migrate
python seed_data.py
python manage.py runserver
```

## Render

`render.yaml` already provisions `community-project-db` and passes its connection string as `DATABASE_URL`.
