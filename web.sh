#!/bin/bash
yum update -y
yum install httpd -y
cat <<EOF > /var/www/html/index.html
<html>
<head>
<title>Hello, Terraform!</title>
</head>
<body>
<h1>Hello, Terraform!</h1>
</body>
</html>
EOF
sudo service httpd start
chkconfig httpd on