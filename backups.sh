aws s3 sync /var/www/halimwebsite/blog/wp-content/ s3://halim.website/wordpress/wp-content
sudo mysqldump wordpress > wordpress.sql
aws s3 cp wordpress.sql s3://halim.website/wordpress/DB-Backup/
sudo rm wordpress.sql