FROM node:7
#FROM rhscl/nodejs-6-rhel7 

# Create directory for application
RUN mkdir -p /app 
WORKDIR /app

# Dependencies are installed here
COPY package.json /app
RUN npm install


# App sourcd
COPY . /app

EXPOSE 8080 
CMD ["node", "payment.js"]
