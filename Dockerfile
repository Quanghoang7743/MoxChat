
# Install React dependencies
RUN npm install

# Build React assets
RUN npm run build

# Set environment variable for port (default to 8000 if not set)
ENV PORT=8000

# Expose the port
EXPOSE $PORT

# Run Laravel server
CMD php artisan serve --host=0.0.0.0 --port=$PORT