data "template_file" "bootstrapCliXXASG" {
  template = file(format("%s/scripts/bootstrapCliXXASG", path.module))
  vars={
    GIT_REPO    ="https://github.com/stackitgit/CliXX_Retail_Repository.git"
    MOUNT_POINT ="/var/www/html"
    WP_CONFIG   ="/var/www/html/wp-config.php"
    DB_HOST_NEW = aws_db_instance.CliXX.endpoint
    LB_DNS      = aws_lb.balance.dns_name 
    DB_USER     = local.db_cred.DB_USER
    DB_PASSWORD = local.db_cred.DB_PASSWORD
    EFS_DNS     = aws_efs_file_system.efs.dns_name
  }
}

data "template_file" "bootstrapBlogASG" {
  template = file(format("%s/scripts/bootstrapBlogASG", path.module))
  vars={
    GIT_REPO    ="https://github.com/elbeloved/STACK_BLOG.git"
    MOUNT_POINT ="/var/www/html/blog"
    WP_CONFIG   ="/var/www/html/wp-config.php"
    db_host_new = aws_db_instance.Blog.endpoint
    LB_DNS      = aws_lb.blog_balance.dns_name 
    db_name     ="wordpressinstance"
    db_user     ="admin"
    db_password ="stackinc"
    db_email    ="ayanfeafelumo@gmail.com"
    EFS_DNS     = aws_efs_file_system.blog_efs.dns_name
  }
}

