#  set the base image to node:18-alpine
FROM node:20-alpine

# create a user with permissions to run the app
# -s -> create a system user
# -g -> add the user to the group
# this is done to avoid running the app as root
# if the app is run as root, it can cause permission issues
# its a good practice to run the app as a non-root user

RUN addgroup app && adduser -S -G app app

# set the user to the app user
USER app

# set the working directory to /app
WORKDIR /app

# copy package.json and package-lock.json tot eh working directory
# this is done before copying the rest of the files to take advantage of docker caching
# if the package.json and package-lock.json files have not changed, docker will use the cached layer
COPY package*.json ./

# sometimes the ownership of the files is changed to root
# this the app cant access the files in throws an error => permission denied
# to avoid this we change the ownership of the files to the node root user

USER root

# change the ownership of the /app dir to the app user
# chown -R <user>:<group> <dir>
# chown command changes the ownership of the files to the user and group specified
RUN chown -R node:node /app

#change the user back to the app user
USER node

# install the dependencies
RUN npm install

# copy the rest of the files to the working directory
COPY . .

# Expose port 5173
EXPOSE 5173

# start the app
CMD ["npm", "run", "dev"] 