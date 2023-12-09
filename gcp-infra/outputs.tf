output "public_ip_vm_01" {
  value       = google_compute_instance.vm-01.network_interface[0].access_config[0].nat_ip
  description = "vm-01 Public IP"
}

# output "public_ip_vm_02" {
#   value       = google_compute_instance.vm-02.network_interface[0].access_config[0].nat_ip
#   description = "vm-02 Public IP"
# }