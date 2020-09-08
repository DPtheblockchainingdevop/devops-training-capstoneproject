FROM nginx:1.19

# Make working dictory ngnix html dirctory
WORKDIR /usr/share/nginx/html/

# Copy index.html to Working Directory
COPY ./index.html .

# Install then run Linter tidy
RUN apt-get update -y && apt-get install -y tidy=1:5.2.0-2
# Lint the html file with tidy
RUN tidy -q -e *.html

# Expose port 80
EXPOSE 80