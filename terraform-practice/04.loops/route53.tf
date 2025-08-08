resource "aws_route53_record" "roboshop_record" {
  count   = length(var.instances)
  zone_id = var.zone_id
  name    = "${var.instances[count.index]}.${var.domain_name}" 
  type    = "A"
  ttl     = 1
  records = [aws_instance.roboshop_instance[count.index].private_ip]
#   records = [
#     var.instances[count.index] == "frontend" ?
#       aws_instance.roboshop_instance[count.index].public_ip :
#       aws_instance.roboshop_instance[count.index].private_ip
#   ]
}