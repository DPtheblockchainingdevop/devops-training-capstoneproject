FROM nginx:latest

# Make working dictory ngnix html dirctory
WORKDIR /usr/share/nginx/html/

# Copy index.html to Working Directory
COPY ./index.html .

# Install then run Linter tidy
RUN apt update && apt-get install -y tidy
# Lint the html file with tidy
RUN tidy -q -e *.html

# Expose port 80
EXPOSE 80