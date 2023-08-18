output "ec2_connect_command" {
  value = [
    for ip in module.ec2_internet.ec2_public_ip : "ssh ${var.ami_user}@${ip}"
  ]
}

/*
output "lambda_status_codes" {
  value = module.lambda_scraper.status_code
}


output "http_status_codes" {
  value = data.http.get_request[*].status_code
}
*/

output "loadbalancer_ip" {
  value = module.ec2_internet.loadbalancer_ip
}