provider "google" {
  project     = "apt-reality-418106"
  region      = "us-central1"
}
resource "google_compute_instance" "default" {
  for_each     =  tomap(var.image_list)
  name         =  each.key
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"
  tags = ["foo", "bar"]
  boot_disk {
    initialize_params {
      image = each.value
      labels = {
        my_label = "value"
      }
    }
  }
  scratch_disk {
    interface = "NVME"
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata = {
    foo = "bar"
    ssh-key = "devops:${file("public.pub")}"
  }

  connection {
    type = "ssh"
    user = "devops"
    private_key = file("private")
    host = self.network_interface[0].network_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install apache2"
    ]
  }
  provisioner "local-exec" {
    command = "sudo apt update && sudo apt -y install apache2"
  }

}
variable "image_list"{
 description = "Image list for creation"
}
