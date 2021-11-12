

resource "google_compute_instance" "demo" {

  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.gcp_zone}"

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

}

output "external_ip"{
  value = "${google_compute_instance.demo.network_interface.0.access_config.0.nat_ip}"
}