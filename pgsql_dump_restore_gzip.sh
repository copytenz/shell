# This guide shows you how to use gzip when pulling down a production database to your local environment
#
# A production database dump can be very large, like 1.5GB
# But database dumps contains a lot of empty space
# Gzipping the database can take the size from 1.5GB down to as low as 50MB
# But you are left zipping and unzipping all the time
#
# Follow these steps to avoid ever creating a large .sql file in the first place
# exporting and importing directly with the gzipped version
# For this example, the production server is named "production"

# On the production server:
# Navigate to your home directory. 
# If this next command fails, it is because you don't have permission to switch to the postgres user
# If so, you will need to login as root before you can run this next command
sudo -u postgres pg_dump DATABASENAME | gzip -9 > DATABASENAME.sql.gz

# You should now have a file in your home directory, and you should be the owner
ls -alh ~/DATABASENAME.sql.gz

# You should see yourself as the owner
# $ -rw-r--r--  1 brock users  45M Oct 15 12:00 DATABASENAME.sql.gz

# If you are not the owner, or if root is the owner, 
# you'll need to change the ownership to yourself before you'll be able download it
# as root:
# chown YOUR_USERNAME_ON_PRODUCTION_SERVER: DATABASENAME.sql.gz
# Note the colon after your username

# Log out of the production server and go back to your local machine
# Use scp to download (-C uses compression for faster downloads)
scp -C production:~/DATABASENAME.sql.gz

# If you already have a local database, the .sql file might complain if you try to import it.
# This can be due to duplicate keys, or if the SQL import attempts to create the table that already exists, etc.
# Only delete the database if you are sure, but I do this all the time
# On OSX, run these commands
drop_db DATABASENAME
create_DB DATABASENAME

# On Linux, the commands are typically
dropdb DATABASENAME
createdb DATABASENAME

# Now re-import the database directly from the gzipped file:
gunzip < DATABASENAME.sql.gz | psql DATABASENAME

# The file remains gzipped both on prod and on your local copy
