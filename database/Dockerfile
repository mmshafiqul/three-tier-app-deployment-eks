# Use PostgreSQL 14 official image
FROM postgres:14

# Set environment variables
ENV POSTGRES_USER=bmi_user
ENV POSTGRES_PASSWORD=admin123
ENV POSTGRES_DB=bmi_db

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy migrations to initialization directory
COPY migrations/*.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=5 \
  CMD pg_isready -U bmi_user -d bmi_db || exit 1

# Default command runs postgres with the specified database
CMD ["postgres"]
